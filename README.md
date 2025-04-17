<p align="center">
  <img src="snap_grid_logo.png" alt="SnapGrid Logo" width="120"/>
</p>

<h1 align="center">SnapGrid</h1>
<p align="center">
  <b>Create stunning screenshot grids from any video, with modern metadata and branding.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ffmpeg-required-brightgreen?logo=ffmpeg"/>
  <img src="https://img.shields.io/badge/ImageMagick-required-orange?logo=imagemagick"/>
  <img src="https://img.shields.io/badge/Bash-CLI-blue?logo=gnubash"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow"/>
</p>

---

![SampleOutput](https://github.com/user-attachments/assets/3c9a3de7-b61f-4231-9d37-8a9bd32258cd)

---

## ✨ Features
- 🎬 Extracts evenly spaced screenshots from any video file
- 🖼️ Customizable grid (screenshots, columns, padding, scaling, gradient background)
- 🏷️ Modern header with filename (no extension) and full video metadata
- 🖌️ User-customizable screenshot borders (color, thickness)
- 🌟 Drop shadow for header text (color, offset customizable)
- 🚀 Logo and tagline branding, auto-scaled and centered
- 📏 All elements scale with output image size
- 📦 Output as PNG or JPG
- 📈 Dynamic title font scaling
- 📊 User-configurable logo height
- 📄 User-configurable header font
- 📐 Robust header layout

## ⚡ Requirements

| Program      | Install Command (Ubuntu/Debian)         | Website                      |
|--------------|-----------------------------------------|------------------------------|
| ffmpeg       | `sudo apt install ffmpeg`               | [ffmpeg.org](https://ffmpeg.org/) |
| ffprobe      | (included with ffmpeg)                  | [ffmpeg.org](https://ffmpeg.org/) |
| ImageMagick  | `sudo apt install imagemagick`          | [imagemagick.org](https://imagemagick.org/) |

> **SnapGrid** is deeply grateful to the creators of [ffmpeg](https://ffmpeg.org/) and [ImageMagick](https://imagemagick.org/) for their incredible open source tools. 🙏

## 🛠️ Installation
1. Install ffmpeg/ffprobe and ImageMagick (see table above).
2. Download or clone this repository:
   ```sh
   git clone https://github.com/neilyboy/SnapGrid.git
   cd SnapGrid
   ```
3. Place your logo file (e.g., `snap_grid_logo.png`) in the directory, or use the default.

## 🚀 Usage
```sh
bash snapgrid.sh -i <input_video> [options]
```

### Main Options
| Option | Description | Default |
|--------|-------------|---------|
| `-i <input_video>` | Input video file | (required) |
| `-o <output_image>` | Output image file | snapgrid_output.png |
| `-s <screenshots>` | Number of screenshots | 20 |
| `-c <columns>` | Grid columns | 5 |
| `-z <percent>` | Output scaling percent | 100 |
| `-p <padding>` | Padding between images (px) | 16 |
| `-b <#hex1,#hex2>` | Gradient background colors | #223344,#5588ff |
| `-l <logo.png>` | Logo file path | snap_grid_logo.png |
| `-t <thumb_width>` | Thumbnail width (px) | 600 |
| `-w <border_width>` | Screenshot border width (px) | 2 |
| `-k <border_color>` | Screenshot border color | #000000 |
| `-S <shadow_color>` | Header text shadow color | #222222 |
| `-O <shadow_offset>` | Header text shadow offset | 2x2 |
| `-C <title_color>` | Title (filename) text color | #ffffff |
| `-M <meta_color>` | Metadata line text color | #ffffff |
| `-G <tagline_color>` | Tagline text color | #ffffff |
| `-U <url_color>` | URL text color | #b0c4ff |
| `-1 <Y\|N>` | Enable drop shadow for title | Y |
| `-2 <Y\|N>` | Enable drop shadow for metadata | Y |
| `-3 <Y\|N>` | Enable drop shadow for tagline | Y |
| `-4 <Y\|N>` | Enable drop shadow for URL | Y |
| `-h` | Show help message | |
| `-T <effect>` | Title effect: `shadow`, `outline`, `none` | shadow |
| `-E <effect>` | Metadata effect: `shadow`, `outline`, `none` | shadow |
| `-Q <effect>` | Tagline effect: `shadow`, `outline`, `none` | shadow |
| `-W <effect>` | URL effect: `shadow`, `outline`, `none` | shadow |
| `--title-outline-color <color>` | Title outline color | #000000 |
| `--title-outline-width <px>` | Title outline width | 2 |
| `--title-shadow-color <color>` | Title shadow color | #222222 |
| `--title-shadow-offset <XxY>` | Title shadow offset | 2x2 |
| `--title-shadow-blur <radius>` | Title shadow blur radius | 0 |
| `--meta-outline-color <color>` | Metadata outline color | #000000 |
| `--meta-outline-width <px>` | Metadata outline width | 2 |
| `--meta-shadow-color <color>` | Metadata shadow color | #222222 |
| `--meta-shadow-offset <XxY>` | Metadata shadow offset | 2x2 |
| `--meta-shadow-blur <radius>` | Metadata shadow blur radius | 0 |
| `--tagline-outline-color <color>` | Tagline outline color | #000000 |
| `--tagline-outline-width <px>` | Tagline outline width | 2 |
| `--tagline-shadow-color <color>` | Tagline shadow color | #222222 |
| `--tagline-shadow-offset <XxY>` | Tagline shadow offset | 2x2 |
| `--tagline-shadow-blur <radius>` | Tagline shadow blur radius | 0 |
| `--url-outline-color <color>` | URL outline color | #000000 |
| `--url-outline-width <px>` | URL outline width | 2 |
| `--url-shadow-color <color>` | URL shadow color | #222222 |
| `--url-shadow-offset <XxY>` | URL shadow offset | 2x2 |
| `--url-shadow-blur <radius>` | URL shadow blur radius | 0 |

### Example
```sh
bash snapgrid.sh -i mymovie.mp4 -s 15 -z 50 -c 4 -b "#222244,#5588ff" -p 10 -t 320 -w 3 -k "#ff0000" -S "#0000ff" -O "4x4" -C "#ffcc00" -M "#00ffcc" -G "#ff00cc" -U "#00aaff" -1 N -2 Y -3 N -4 Y -o thumbs.png
```

### Example: Outline, Shadow, and Blur
```sh
# Title with outline, metadata with blurred shadow, tagline plain, URL with colored outline
bash snapgrid.sh -i mymovie.mp4 \
  -T outline --title-outline-color "#ffffff" --title-outline-width 4 \
  -E shadow --meta-shadow-color "#000000" --meta-shadow-offset "4x4" --meta-shadow-blur 6 \
  -Q none \
  -W outline --url-outline-color "#ff00ff" --url-outline-width 3 \
  -o thumbs.png
```

---

## 🎨 Advanced Customization

Each header text element (title, metadata, tagline, URL) supports these effects:

- **shadow:** Adds a drop shadow with customizable color, offset, and optional blur for a soft look.
  - Example: `-T shadow --title-shadow-color "#222222" --title-shadow-offset "3x3" --title-shadow-blur 5`
- **outline:** Adds a crisp border around the text with customizable color and width.
  - Example: `-T outline --title-outline-color "#ff00ff" --title-outline-width 4`
- **none:** Plain text, no shadow or outline.

Mix and match per element:
- `-T`, `-E`, `-Q`, `-W` set the effect for title, metadata, tagline, and URL respectively.
- Use the corresponding `--*-outline-*` and `--*-shadow-*` options to control appearance.

**Tip:** For maximum readability, use a blurred shadow or a high-contrast outline depending on your background.

## 🖼️ Output Example
<p align="center">
  <img src="sample_output.png" alt="SnapGrid Output Example" width="90%"/>
</p>

## ❓ FAQ
**Q: My output is blank or corrupt!**  
A: Ensure your input file exists and that ffmpeg/ffprobe/ImageMagick are installed and available in your PATH.

**Q: How do I change the logo?**  
A: Place your PNG logo in the directory and use `-l <logo.png>`.

**Q: Can I use this on Windows?**  
A: Yes! Use Git Bash or WSL, and ensure ffmpeg and ImageMagick are installed.

## 🤝 Contributing
Pull requests and suggestions are welcome! Please open an issue or PR.

## 📝 License
MIT

---

<p align="center">
  <sub>Created with ❤️ by <a href="https://github.com/neilyboy">neilyboy</a> – Powered by <a href="https://ffmpeg.org/">ffmpeg</a> & <a href="https://imagemagick.org/">ImageMagick</a></sub>
</p>

## Using and Creating Theme Scripts

You can save your favorite SnapGrid settings as a theme script for easy reuse. Just copy or create a shell script (e.g. `moon_phases_theme.sh`) in the same directory as `snapgrid.sh`.

### Example: Moon Phases Theme

```bash
# moon_phases_theme.sh
#!/bin/bash
# Usage: ./moon_phases_theme.sh <inputfile> [outputfile]
DIR="$(dirname "$0")"
"$DIR/snapgrid.sh" -i "$1" -o "${2:-${1%.*}_moonphases.png}" \
  -C '#212A31' -M '#748D92' -G '#124E66' -U '#D3D9D4' \
  -T shadow -E outline -Q none -W shadow \
  --title-color '#D3D9D4' --tagline-color '#D3D9D4' \
  --logo-height 64 --header-font 'DejaVu-Sans' \
  --title-shadow-color '#748D92' --title-shadow-blur 2 \
  --title-outline-color '#124E66' --title-outline-width 2
```

#### To use the theme:
```bash
chmod +x moon_phases_theme.sh
./moon_phases_theme.sh MyVideo.mkv
```

### Making Your Own Theme
- Copy `moon_phases_theme.sh` and change the color and style variables at the top.
- You can set any SnapGrid option in your theme script.
- Save as `your_theme_name.sh` and run it with your video file as the argument.

#### Example:
```bash
cp moon_phases_theme.sh my_custom_theme.sh
# Edit my_custom_theme.sh and change colors/effects
./my_custom_theme.sh input.mp4
```

---

Themes make it easy to keep your SnapGrid style consistent and share your favorite looks with others!

## Advanced Header Customization

### Dynamic Title Font Scaling
- The title (filename) will automatically shrink to fit the available width in the header.
- The maximum width for the title is set to nearly the full header width, leaving only enough space for the logo and padding on the right.
- Font scaling is automatic; you can adjust the default and minimum font sizes in the script:
  - `TITLE_FONT_SIZE` (default, based on thumbnail height)
  - `MIN_TITLE_FONT_SIZE` (default: 18)

### User-Configurable Logo Height
- The logo in the header is always resized to a user-configurable height.
- Change the logo height by editing the `LOGO_HEIGHT_PX` variable near the top of `snapgrid.sh` (default: 72 pixels).
- Example:
  ```bash
  LOGO_HEIGHT_PX=64  # Set logo height to 64px
  ```

### User-Configurable Header Font
- The font for the title is user-configurable via the `HEADER_FONT_FILE` variable near the top of `snapgrid.sh`.
- Default: `DejaVu-Sans` (available on most systems). You may change to any installed font, e.g. `Liberation-Sans`, `Arial`, etc.
- Example:
  ```bash
  HEADER_FONT_FILE="Liberation-Sans"
  ```

### Robust Header Layout
- **Left side (stacked):** Title (filename) and metadata.
- **Right side (stacked):** Logo, tagline, and URL, all right-justified and stacked vertically.
- The title can extend nearly to the logo for maximum space.
- No overlap is possible, even with very long filenames.

### Example Usage

```bash
./snapgrid.sh -i input.mp4 -o output.png \
  -C '#ffffff' -M '#cccccc' -G '#b0c4ff' -U '#b0c4ff' \
  -T shadow -E outline -Q none -W shadow \
  # (and any other options)
```

#### Customizing Logo and Font
- To use a different logo, place your PNG file as `snap_grid_logo.png` in the same directory as `snapgrid.sh`.
- To change logo size, edit `LOGO_HEIGHT_PX` at the top of the script.
- To change the title font, edit `HEADER_FONT_FILE` at the top of the script.

### Notes
- The script will always ensure the title fits the allowed space, even for extremely long filenames.
- If you encounter font warnings, set `HEADER_FONT_FILE` to a font that is installed on your system (see `fc-list` for available fonts).

---

For more details on all options, see the comments at the top of `snapgrid.sh` or run:
```bash
./snapgrid.sh -h
