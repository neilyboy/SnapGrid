#!/bin/bash
# SnapGrid: Bash version - modern video screenshot grid generator
# Requirements: ffmpeg, ffprobe, ImageMagick (convert, montage, composite)

set -e
set -u

# --- DEFAULTS ---
screens=20
size=100
columns=5
padding=16
BG1="#223344"
BG2="#5588ff"
LOGO="snap_grid_logo.png"
OUTPUT="snapgrid_output.png"
TAGLINE="Created by SnapGrid"
URL="https://github.com/neilyboy/SnapGrid"
thumb_width=600  # Increased from 320 for better readability
BORDER_WIDTH=2   # Default border width (px, integer)
BORDER_COLOR="#000000" # Default border color (black)
SHADOW_COLOR="#222222"  # Default text shadow color
SHADOW_OFFSET="2x2"     # Default shadow offset (ImageMagick format: +x+y)

usage() {
  echo "Usage: $0 -i <input_video> [options]"
  echo "Options:"
  echo "  -i <input_video>      Input video file (required)"
  echo "  -o <output_image>     Output image file (default: snapgrid_output.png)"
  echo "  -s <screenshots>      Number of screenshots (default: 20)"
  echo "  -c <columns>          Grid columns (default: 5)"
  echo "  -z <percent>          Output scaling percent (default: 100)"
  echo "  -p <padding>          Padding in pixels (default: 16)"
  echo "  -b <#hex1,#hex2>      Background gradient (default: #223344,#5588ff)"
  echo "  -l <logo.png>         Logo file path (default: snap_grid_logo.png)"
  echo "  -t <thumb_width>      Thumbnail width in px (default: 600)"
  echo "  -w <border_width>     Screenshot border width in px (default: 2)"
  echo "  -k <border_color>     Screenshot border color (default: #000000)"
  echo "  -S <shadow_color>     Header text shadow color (default: #222222)"
  echo "  -O <shadow_offset>    Header text shadow offset (default: 2x2)"
  echo "  -h                    Show this help message"
  exit 1
}

# --- PARSE ARGS ---
while getopts "i:o:s:c:z:p:b:l:t:w:k:S:O:h" opt; do
  case $opt in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    s) screens="$OPTARG" ;;
    c) columns="$OPTARG" ;;
    z) size="$OPTARG" ;;
    p) padding="$OPTARG" ;;
    b)
      BG1=$(echo "$OPTARG" | cut -d, -f1)
      BG2=$(echo "$OPTARG" | cut -d, -f2)
      ;;
    l) LOGO="$OPTARG" ;;
    t) thumb_width="$OPTARG" ;;
    w) BORDER_WIDTH="$OPTARG" ;;
    k) BORDER_COLOR="$OPTARG" ;;
    S) SHADOW_COLOR="$OPTARG" ;;
    O) SHADOW_OFFSET="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [ -z "${INPUT:-}" ]; then
  usage
fi

if ! command -v ffmpeg &>/dev/null || ! command -v ffprobe &>/dev/null || ! command -v convert &>/dev/null || ! command -v montage &>/dev/null; then
  echo "Error: ffmpeg, ffprobe, and ImageMagick (convert, montage) must be installed." >&2
  exit 1
fi

BASENAME_NOEXT="$(basename "$INPUT" | sed 's/\.[^.]*$//')"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# --- GET VIDEO METADATA ---
META=$(ffprobe -v error -show_entries format=duration:format=bit_rate:format=size:stream=width,height,codec_name,avg_frame_rate,codec_type,codec_long_name -of default=noprint_wrappers=1 "$INPUT")
DURATION=$(echo "$META" | grep '^duration=' | cut -d= -f2 | awk '{printf("%.0f", $1)}')
WIDTH=$(echo "$META" | grep '^width=' | head -1 | cut -d= -f2)
HEIGHT=$(echo "$META" | grep '^height=' | head -1 | cut -d= -f2)
CODEC=$(echo "$META" | grep '^codec_name=' | head -1 | cut -d= -f2)
FPS_RAW=$(echo "$META" | grep '^avg_frame_rate=' | head -1 | cut -d= -f2)
FPS=$(awk -F'/' '{if ($2>0) printf("%.2f", $1/$2); else print "?"}' <<< "$FPS_RAW")
BITRATE=$(echo "$META" | grep '^bit_rate=' | head -1 | cut -d= -f2)
BITRATE_MBPS=$(awk 'BEGIN{printf "%.2f", ARGV[1]/1000000}' "$BITRATE")
FILESIZE=$(echo "$META" | grep '^size=' | head -1 | cut -d= -f2)
FILESIZE_HR=$(awk '{if ($1 > 1073741824) printf("%.2f GB", $1/1073741824); else if ($1 > 1048576) printf("%.2f MB", $1/1048576); else printf("%d bytes", $1)}' <<< "$FILESIZE")
AUDIO_CODEC=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$INPUT" | head -1)

# --- Format duration to HH:MM:SS ---
dur_h=$((DURATION/3600))
dur_m=$(( (DURATION%3600)/60 ))
dur_s=$(( DURATION%60 ))
DURATION_FMT=$(printf "%02d:%02d:%02d" $dur_h $dur_m $dur_s)

# --- Calculate thumbnail height to preserve aspect ratio ---
thumb_height=$(( thumb_width * HEIGHT / WIDTH ))
# Increase header height for logo/text
header_h=$((thumb_height / 1 + padding * 4))  # header now as tall as a thumb + extra padding

echo "[SnapGrid] Extracting screenshots..."
# --- EXTRACT SCREENSHOTS ---
for i in $(seq 1 $screens); do
  TS=$(awk -v dur="$DURATION" -v n="$screens" -v i="$i" 'BEGIN { printf("%.2f", dur*i/(n+1)) }')
  ffmpeg -loglevel error -ss "$TS" -i "$INPUT" -frames:v 1 -q:v 2 "$TMPDIR/snapgrid_$i.jpg"
  # Resize to thumbnail width/height, force aspect
  convert "$TMPDIR/snapgrid_$i.jpg" -resize ${thumb_width}x${thumb_height}! \
    -bordercolor "$BORDER_COLOR" -border ${BORDER_WIDTH} "$TMPDIR/snapgrid_$i.jpg"
done

echo "[SnapGrid] Composing grid..."
# --- MAKE GRID ---
rows=$(( (screens + columns - 1) / columns ))
num_thumbs=$(ls "$TMPDIR"/snapgrid_*.jpg | wc -l)
montage "$TMPDIR"/snapgrid_*.jpg -geometry +${padding}+${padding} -tile ${columns}x${rows} -background none "$TMPDIR/grid.png"
# Check grid size and warn if too large
GRIDW=$(identify -format "%w" "$TMPDIR/grid.png")
GRIDH=$(identify -format "%h" "$TMPDIR/grid.png")
MAX_SIZE=8000  # Allow larger output
if [ "$GRIDW" -gt "$MAX_SIZE" ] || [ "$GRIDH" -gt "$MAX_SIZE" ]; then
  echo "Error: Output grid size ${GRIDW}x${GRIDH} exceeds ${MAX_SIZE}px in width or height. Reduce thumbnail width (-t), columns (-c), or screenshots (-s)." >&2
  exit 1
fi

# --- CREATE BACKGROUND GRADIENT (fix for full smooth gradient) ---
# Create gradient at full output size
OUTW=$GRIDW
OUTH=$((GRIDH + header_h + padding * 2))
convert -size ${OUTW}x${OUTH} gradient:${BG1}-${BG2} "$TMPDIR/bg.png"

# --- COMPOSITE GRID ON BG (no extra cropping, keep full gradient) ---
convert "$TMPDIR/bg.png" "$TMPDIR/grid.png" -geometry +0+${header_h} -composite "$TMPDIR/composite.png"

echo "[SnapGrid] Adding header and branding..."
# --- DRAW HEADER TEXT ---
HEADER1="$BASENAME_NOEXT"
HEADER2="Codec: $CODEC | Resolution: ${WIDTH}x${HEIGHT} | Duration: ${DURATION_FMT} | Bitrate: ${BITRATE_MBPS} Mbps | FPS: ${FPS} | Audio: ${AUDIO_CODEC} | Size: ${FILESIZE_HR}"
HEADER_FONT=$((thumb_height/5))   # smaller
INFO_FONT=$((thumb_height/9))     # much smaller
HEADER_LINE_Y=$((header_h/2 - HEADER_FONT/2 - 10))  # center block
META_Y=$((HEADER_LINE_Y + HEADER_FONT + 24))        # extra space below filename

# Draw shadow first, then main text for both header lines
convert "$TMPDIR/composite.png" \
  -fill "$SHADOW_COLOR" -gravity NorthWest -pointsize $HEADER_FONT -annotate +$((padding*2+${SHADOW_OFFSET%%x*}))+$((HEADER_LINE_Y+${SHADOW_OFFSET#*x})) "$HEADER1" \
  -fill white -gravity NorthWest -pointsize $HEADER_FONT -annotate +$((padding*2))+$HEADER_LINE_Y "$HEADER1" \
  -fill "$SHADOW_COLOR" -gravity NorthWest -pointsize $INFO_FONT -annotate +$((padding*2+${SHADOW_OFFSET%%x*}))+$((META_Y+${SHADOW_OFFSET#*x})) "$HEADER2" \
  -fill white -gravity NorthWest -pointsize $INFO_FONT -annotate +$((padding*2))+$META_Y "$HEADER2" \
  "$TMPDIR/headered.png"

# --- ADD LOGO AND TAGLINE IN HEADER ---
# Calculate fonts for tagline and URL (always set, regardless of logo)
TAG_FONT=$((thumb_height/7))
URL_FONT=$((thumb_height/10))

if [ -f "$LOGO" ]; then
  # Make logo 25% smaller than before
  LOGOW=$(awk "BEGIN {printf \"%d\", $header_h / 2.67}")
  # Calculate total block height (logo + tagline + URL + spacing)
  LOGO_BLOCK_H=$((LOGOW + TAG_FONT + URL_FONT + 30))
  # Center the block vertically in the header
  LOGO_Y=$(( (header_h - LOGO_BLOCK_H) / 2 ))
  LOGOPAD=$((padding*2))
  convert "$LOGO" -resize x${LOGOW} "$TMPDIR/logo.png"
  composite -gravity NorthEast -geometry +${LOGOPAD}+${LOGO_Y} "$TMPDIR/logo.png" "$TMPDIR/headered.png" "$TMPDIR/logoed.png"
else
  cp "$TMPDIR/headered.png" "$TMPDIR/logoed.png"
fi
# Vertically center tagline and URL below logo (always use TAG_FONT and URL_FONT)
LOGOPAD=$((padding*2))
LOGO_Y=$(( (header_h - (TAG_FONT + URL_FONT + 30)) / 2 ))
convert "$TMPDIR/logoed.png" \
  -gravity NorthEast -fill white -pointsize $TAG_FONT -annotate +$((LOGOPAD))+$(($LOGO_Y + 10)) "$TAGLINE" \
  -gravity NorthEast -fill '#b0c4ff' -pointsize $URL_FONT -annotate +$((LOGOPAD))+$(($LOGO_Y + TAG_FONT + 20)) "$URL" \
  "$TMPDIR/final.png"

echo "[SnapGrid] Finalizing output..."
# --- SCALE OUTPUT IF NEEDED ---
if [ "$size" != "100" ]; then
  convert "$TMPDIR/final.png" -resize ${size}% "$OUTPUT"
else
  cp "$TMPDIR/final.png" "$OUTPUT"
fi

# --- Fix possible bottom line artifact by cropping 1px if needed ---
convert "$OUTPUT" -crop x$((OUTH-1))+0+0 +repage "$OUTPUT"

echo "[SnapGrid] Done! Output saved to $OUTPUT"
