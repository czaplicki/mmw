mmw(1)

# NAME
mmw - generate per-monitor wallpapers

# SYNOPSIS
*mmw* _IMAGE_ [options]

# DESCRIPTION
mmw creates individual wallpapers for each active Wayland output
using the compositor layout as reported by wlr-randr.

By default, images are written to a temporary directory and the resulting
paths are printed to standard output.

# OPTIONS
*-V*, *--vertical-alignment*=_top|center|bottom_
Vertical crop alignment (default: center)

*-H*, *--horizontal-alignment*=_left|center|right_
Horizontal crop alignment (default: center)

*-o*, *--outputs*=_OUTPUT,OUTPUT_
Only generate wallpapers for these outputs

*-i*, *--ignore-outputs*=_OUTPUT,OUTPUT_
Ignore these outputs

*-s*, *--save*=_PATH_
Directory to save generated wallpapers

*--preview*
Generate a preview image showing crop regions

*--apply*
Apply wallpapers immediately using swaybg

*--dry-run*
Do not write files or apply wallpapers

*--json*
Output a JSON object mapping outputs to image paths

*--verbose*
Enable verbose logging to stderr

# OUTPUT
When *--json* is not used, mmw prints one image path per line.
When *--json* is used, a JSON object is printed.

# EXAMPLES
Generate wallpapers:
