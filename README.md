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
| `-h` | Show help message | |

### Example
```sh
bash snapgrid.sh -i mymovie.mp4 -s 15 -z 50 -c 4 -b "#222244,#5588ff" -p 10 -t 320 -w 3 -k "#ff0000" -S "#0000ff" -O "4x4" -o thumbs.png
```

---

## 🎨 Customization
- **Logo:** Place `snap_grid_logo.png` in the script directory, or specify with `-l`.
- **Borders:** Use `-w` and `-k` for border thickness and color.
- **Text Shadow:** Use `-S` and `-O` for shadow color and offset.
- **Gradient:** Use `-b` for custom background gradients.

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
