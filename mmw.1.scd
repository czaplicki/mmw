mmw(1)

# NAME
mmw - generate per-monitor wallpapers

# SYNOPSIS
*mmw* _IMAGE_ [_MONITORS_] [options]

# DESCRIPTION
`mmw` creates individual wallpapers for each active monitor based on its geometry and position.
It can detect monitor layouts automatically on many Wayland compositors and X11.

By default, images are written to a temporary directory and the resulting
paths are printed to standard output, one per line.

The _MONITORS_ argument is optional and can be used to manually specify monitor layouts.
If set to '-', layouts are read from standard input. See the *MONITOR SYNTAX* section for details.

# POSITIONAL ARGUMENTS
*_IMAGE_*
: The image to use as a source for the wallpapers.

*_MONITORS_*
: An optional string describing the monitor layout. If omitted, `mmw` attempts to autodetect the layout.
If set to `-`, monitor descriptions are read from stdin.
This can be either a custom format string or JSON if `--json-input` is used.

# OPTIONS
*-j*, *--json*
: Output a JSON object mapping monitor names to generated image paths.

*-J*, *--json-input*
: Parse the _MONITORS_ argument (or stdin) as JSON. See *MONITOR SYNTAX*.

*-o*, *--out*=_PATH_
: Directory to save generated wallpapers to. If not provided, a temporary directory is used.

*-f*, *--out-format*=_FMT_
: Format for the names of generated images. (default: "%o.%n.%e").
The following substitutions are available:
  - *%o*: monitor name (or "preview")
  - *%n*: original image name without extension
  - *%e*: original image extension
  - *%N*: original image name with extension

*-i*, *--ignore*=_OUTPUT,OUTPUT_
: Comma-separated list of monitors to ignore.

*-p*, *--preview*
: Instead of generating cropped wallpapers, generate a single preview image showing the planned crop regions for each monitor.

*-e*, *--exec*=_CMD_
: Execute a command for each generated image instead of printing its path.
The following substitutions are available in the command string:
  - *%p*: path to the generated image
  - *%o*: the monitor name

*-O*, *--orphan*
: When using *--exec*, spawn the command as an orphaned process and exit immediately without waiting for it to complete.

*-V*, *--vertical-alignment*=_top|center|bottom_
: Vertical alignment for the crop on the source image. (default: center)

*-H*, *--horizontal-alignment*=_left|center|right_
: Horizontal alignment for the crop on the source image. (default: center)

*--verbose*
: Enable verbose logging to stderr.

*--debug*
: Enable debug logging to stderr.

*--dry-run*
: Perform all calculations but do not write any image files.

# MONITOR SYNTAX

## String Format
When not using *--json-input*, monitors are described with a comma-separated string.
Each monitor has the format: `NAME:WIDTHxHEIGHT+X+Y`
Example: `DP-1:1920x1080+0+0,HDMI-A-1:1920x1080+1920+0`

## JSON Format
When using *--json-input*, provide a JSON array of objects, where each object represents a monitor.
e.g.
```json
[
  {
    "name": "DP-1",
    "w": 1920,
    "h": 1080,
    "x": 0,
    "y": 0
  },
  {
    "name": "HDMI-A-1",
    "w": 1920,
    "h": 1080,
    "x": 1920,
    "y": 0
  }
]
```

# EXAMPLES
Generate wallpapers for all detected monitors and print their paths:
`$ mmw wallpaper.jpg`

Generate a preview of the crop layout:
`$ mmw wallpaper.jpg --preview`

Generate wallpapers and set them using `swaybg`:
`$ mmw wallpaper.jpg --exec "swaybg --image %p --output %o"`

Generate wallpapers in a specific directory with a custom name format:
`$ mmw image.png --out ~/Pictures/wallpapers -f "%n-%o.%e"`

Pass monitor layout manually via stdin:
`$ echo "VIRTUAL-1:3840x1080+0+0" | mmw wallpaper.jpg -`

Output paths as JSON for scripting:
```
$ mmw wallpaper.jpg --json
{
  "DP-1": "/tmp/tmp.XXXX/DP-1.wallpaper.jpg",
  "HDMI-A-1": "/tmp/tmp.XXXX/HDMI-A-1.wallpaper.jpg"
}
```