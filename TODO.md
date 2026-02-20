# Todo
* Warn/quit on image to smol

# Options

# Potental addition
? "-E, --exec-once <CMD>" Run `CMD` on outout
  - subsitutes:
    - %n with space separated `output-name`/"preview" names
    - %p with space spearated paths to genereate images
    - %<output-name> with path to generated image for that output
  - example:
    # opens all generated images in swayimg
    - wwm <img> -e 'swayimg %p'

? "-P, --terminal-preview"
  - shows a text representstion of the planed crops

? "-s, --scale <float>"
  - Scale the image before proccessing

? "-S, --auto-scale"
  - Automatically scale to small images to work, instead of failing
