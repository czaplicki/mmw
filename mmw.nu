
#!/usr/bin/env nu

def log [msg: string, verbose: bool] {
  if $verbose {
    $"[gen-wall] ($msg)\n" | save --append /dev/stderr
  }
}

def main [
  image: path

  --vertical-alignment (-V): string = "center"
  --horizontal-alignment (-H): string = "center"

  --outputs (-o): string
  --ignore-outputs (-i): string

  --save (-s): path
  --preview
  --apply
  --dry-run
  --json
  --verbose
] {
  if not ($image | path exists) {
    error make { msg: $"Image not found: ($image)" }
  }

  # -------------------------
  # Output directory
  # -------------------------
  let out_dir = if $save != null {
    mkdir $save
    $save
  } else {
    let tmp = (mktemp -d)
    log $"using temp dir: ($tmp)" $verbose
    $tmp
  }

  # -------------------------
  # Image size
  # -------------------------
  let dims = (
    magick identify -format "%w %h" $image
    | split row " "
    | into int
  )
  let img_w = $dims.0
  let img_h = $dims.1

  log $"image size: ($img_w)x($img_h)" $verbose

  # -------------------------
  # Outputs (JSON)
  # -------------------------
  let state = (wlr-randr --json | from json)

  let requested = if $outputs != null { $outputs | split row "," } else { [] }
  let ignored   = if $ignore_outputs != null { $ignore_outputs | split row "," } else { [] }

  let outputs = (
    $state.outputs
    | where enabled
    | where {|o|
        ( ($requested | is-empty) or ($requested | any { $it == $o.name }) )
        and not ($ignored | any { $it == $o.name })
      }
    | each {|o|
        let w = $o.current_mode.width
        let h = $o.current_mode.height

        if $o.transform in ["90" "270"] {
          { name: $o.name, x: $o.position.x, y: $o.position.y, w: $h, h: $w }
        } else {
          { name: $o.name, x: $o.position.x, y: $o.position.y, w: $w, h: $h }
        }
      }
  )

  if ($outputs | is-empty) {
    error make { msg: "No outputs selected" }
  }

  # -------------------------
  # Layout bounds
  # -------------------------
  let min_x = ($outputs.x | math min)
  let min_y = ($outputs.y | math min)
  let max_x = ($outputs | each {|o| $o.x + $o.w } | math max)
  let max_y = ($outputs | each {|o| $o.y + $o.h } | math max)

  let layout_w = $max_x - $min_x
  let layout_h = $max_y - $min_y

  # -------------------------
  # Alignment offsets
  # -------------------------
  let off_x = match $horizontal_alignment {
    "left" => 0
    "center" => (($img_w - $layout_w) / 2 | into int)
    "right" => ($img_w - $layout_w)
  }

  let off_y = match $vertical_alignment {
    "top" => 0
    "center" => (($img_h - $layout_h) / 2 | into int)
    "bottom" => ($img_h - $layout_h)
  }

  # -------------------------
  # Compute results
  # -------------------------
  let results = (
    $outputs
    | each {|o|
        let cx = $o.x - $min_x + $off_x
        let cy = $o.y - $min_y + $off_y

        let out = $"($out_dir)/($image | path stem).($o.name).($image | path extension)"

        {
          name: $o.name
          path: $out
          crop: $"($o.w)x($o.h)+($cx)+($cy)"
        }
      }
  )

  # -------------------------
  # Preview
  # -------------------------
  if $preview {
    let preview_out = $"($out_dir)/($image | path stem).preview.($image | path extension)"

    let draw = (
      $results
      | each {|r|
          $"-stroke red -fill none -strokewidth 6 -draw rectangle " +
          $"({$r.crop | split row '+' | get 1}),({$r.crop | split row '+' | get 2})"
        }
    )

    if not $dry_run {
      magick $image ...$draw $preview_out
    }

    print $preview_out
    return
  }

  # -------------------------
  # Generate + apply
  # -------------------------
  for r in $results {
    log $"crop ($r.name): ($r.crop)" $verbose

    if not $dry_run {
      magick $image -crop $r.crop +repage $r.path
    }

    if ($apply and not $dry_run) {
      swaybg -o $r.name -i $r.path -m fill | ignore
    }
  }

  # -------------------------
  # Output
  # -------------------------
  if $json {
    $results
    | reduce --fold {} {|r, acc| $acc | upsert $r.name $r.path }
    | to json
    | print
  } else {
    $results | each { print $in.path }
  }
}
