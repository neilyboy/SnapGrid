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

<p align="center">
  <img src="sample_output.png" alt="SnapGrid Example Output" width="90%"/>
</p>

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
