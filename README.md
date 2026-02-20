# mmw - Multi Monitor Wallpaper

**mmw** is a CLI utility that takes a single large image and slices it into perfectly aligned wallpapers for your multi-monitor setup. It handles the geometry calculations to ensure your background spans seamlessly across screens of different resolutions and positions.

Designed for the scripters, it integrates smoothly with window managers like Sway, Hyprland, and other Wayland compositors (with X11 fallback support).

## Features

- **Auto-Detection**: Automatically queries your monitor layout using `wlr-randr` (Wayland) or `xrandr` (X11/GNOME).
- **Pixel-Perfect Cuts**: Generates individual image files cropped exactly for each display's resolution and position.
- **Preview Mode**: Visualize how the image will be cut before generating the final files.
- **Scriptable**:
    - **JSON Output**: Get paths to generated images in JSON format.
    - **Exec Hooks**: Run a command for each generated wallpaper (e.g., to immediately set it with `swaybg` or `swww`).
    - **Stdin Support**: Pipe in monitor layouts manually for complex or headless setups.
- **Nushell Powered**: Written in pure Nushell for modern, structured data processing.

## Installation

### Using Nix (Flakes)

You can run `mmw` directly without installing:

```bash
nix run github:czaplicki/mmw -- ./path/to/image.jpg
```

Or add it to your system configuration/flake.

### Manual Installation

1.  **Dependencies**: Ensure you have the following installed:
    -   [`nushell`](https://www.nushell.sh/) (The shell it's written in)
    -   [`imagemagick`](https://imagemagick.org/) (For image processing)
    -   [`wlr-randr`](https://gitlab.freedesktop.org/emersion/wlr-randr/) (For Wayland monitor detection)
    -   [`wayland-utils`](https://gitlab.freedesktop.org/wayland/wayland-utils) wayland-utils (Query wayland compositor protocalls) 
    -   `xrandr` (For X11 monitor detection)

2.  **Install**:
    Copy the `mmw` script to a location in your `$PATH`.

    ```bash
    cp mmw/mmw.nu ~/.local/bin/mmw
    chmod +x ~/.local/bin/mmw
    ```

## Usage

Basic usage to generate wallpapers in a temporary directory:

```bash
mmw ./wallpaper.jpg
```

### Common Examples

**Preview the cuts:**
Generates a single image showing where the cuts will be made.

```bash
mmw ./wallpaper.jpg --preview
# Open the resulting path in your image viewer
```

**Set wallpapers immediately (Sway/Hyprland):**
Use the `--exec` flag to run a command for each generated image. `%o` is replaced by the monitor name, and `%p` by the image path.

```bash
# Using swaybg
mmw ./wallpaper.jpg --exec "swaybg --output %o --image %p --mode fill"

# Using swww
mmw ./wallpaper.jpg --exec "swww img -o %o %p"
```

**Save to a specific directory:**

```bash
mmw ./wallpaper.jpg --out ~/Pictures/Wallpapers/Current
```

**JSON Output for Scripting:**

```bash
mmw ./wallpaper.jpg --json
# Output: { "DP-1": "/tmp/.../DP-1.wallpaper.jpg", "HDMI-A-1": "/tmp/.../HDMI-A-1.wallpaper.jpg" }
```

**Manual Layout (Advanced):**
Pipe a custom layout definition into `mmw`. Useful for testing or specific non-detected setups.

```bash
# Format: NAME:WxH+X+Y
echo "DP-1:1920x1080+0+0,HDMI-1:2560x1440+1920+0" | mmw ./wallpaper.jpg -
```

## Options

| Flag | Description |
| :--------------------------- | :---------------------------------------------------- |
| `-o, --out <PATH>`           | Directory to save generated wallpapers.               |
| `-f, --out-format <FMT>`     | Filename format (default: `%o.%n.%e`).                |
| `-p, --preview`              | Generate a preview image instead of individual crops. |
| `-e, --exec <CMD>`           | Command to execute for each output file.              |
| `-j, --json`                 | Output paths as a JSON object.                        |
| `-J, --json-input`           | Read monitor layout as JSON from stdin/args.          |
| `-V, --vertical-alignment`   | `top`, `center`, `bottom` (default: `center`).        |
| `-H, --horizontal-alignment` | `left`, `center`, `right` (default: `center`).        |

See `man mmw` (or `mmw.1.scd`) for full documentation.

## License

MIT
