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
TITLE_COLOR="#ffffff"      # Main filename/title (default: white)
META_COLOR="#ffffff"       # Metadata line (default: white)
TAGLINE_COLOR="#ffffff"    # Tagline text (default: white)
URL_COLOR="#b0c4ff"        # URL text (default: blue)
TITLE_SHADOW=Y
META_SHADOW=Y
TAGLINE_SHADOW=Y
URL_SHADOW=Y

# --- TEXT EFFECTS (shadow, outline, none) ---
TITLE_EFFECT=shadow   # Options: shadow, outline, none
META_EFFECT=shadow
TAGLINE_EFFECT=shadow
URL_EFFECT=shadow

# Outline options (per text entity)
TITLE_OUTLINE_COLOR="#000000"
TITLE_OUTLINE_WIDTH=2
META_OUTLINE_COLOR="#000000"
META_OUTLINE_WIDTH=2
TAGLINE_OUTLINE_COLOR="#000000"
TAGLINE_OUTLINE_WIDTH=2
URL_OUTLINE_COLOR="#000000"
URL_OUTLINE_WIDTH=2

# Shadow options (per text entity)
TITLE_SHADOW_COLOR="#222222"
TITLE_SHADOW_OFFSET="2x2"
TITLE_SHADOW_BLUR=0
META_SHADOW_COLOR="#222222"
META_SHADOW_OFFSET="2x2"
META_SHADOW_BLUR=0
TAGLINE_SHADOW_COLOR="#222222"
TAGLINE_SHADOW_OFFSET="2x2"
TAGLINE_SHADOW_BLUR=0
URL_SHADOW_COLOR="#222222"
URL_SHADOW_OFFSET="2x2"
URL_SHADOW_BLUR=0

# --- USER-CONFIGURABLE LOGO HEIGHT (in pixels) ---
LOGO_HEIGHT_PX=72  # Change this to your preferred logo height

# --- USER-CONFIGURABLE HEADER FONT (must be installed on your system) ---
HEADER_FONT_FILE="DejaVu-Sans"  # Change to any installed font name (e.g. Arial, Liberation-Sans)

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
  echo "  -C <title_color>      Title (filename) text color (default: #ffffff)"
  echo "  -M <meta_color>       Metadata line text color (default: #ffffff)"
  echo "  -G <tagline_color>    Tagline text color (default: #ffffff)"
  echo "  -U <url_color>        URL text color (default: #b0c4ff)"
  echo "  -1 <Y|N>             Enable drop shadow for title (default: Y)"
  echo "  -2 <Y|N>             Enable drop shadow for metadata (default: Y)"
  echo "  -3 <Y|N>             Enable drop shadow for tagline (default: Y)"
  echo "  -4 <Y|N>             Enable drop shadow for URL (default: Y)"
  echo "  -T <effect>          Title effect: shadow|outline|none (default: shadow)"
  echo "  -E <effect>          Metadata effect: shadow|outline|none (default: shadow)"
  echo "  -Q <effect>          Tagline effect: shadow|outline|none (default: shadow)"
  echo "  -W <effect>          URL effect: shadow|outline|none (default: shadow)"
  echo "  --title-outline-color <color>    (default: #000000)"
  echo "  --title-outline-width <px>       (default: 2)"
  echo "  --title-shadow-color <color>     (default: #222222)"
  echo "  --title-shadow-offset <XxY>      (default: 2x2)"
  echo "  --title-shadow-blur <radius>     (default: 0)"
  echo "  --meta-outline-color <color>     (default: #000000)"
  echo "  --meta-outline-width <px>        (default: 2)"
  echo "  --meta-shadow-color <color>      (default: #222222)"
  echo "  --meta-shadow-offset <XxY>       (default: 2x2)"
  echo "  --meta-shadow-blur <radius>      (default: 0)"
  echo "  --tagline-outline-color <color>  (default: #000000)"
  echo "  --tagline-outline-width <px>     (default: 2)"
  echo "  --tagline-shadow-color <color>   (default: #222222)"
  echo "  --tagline-shadow-offset <XxY>    (default: 2x2)"
  echo "  --tagline-shadow-blur <radius>   (default: 0)"
  echo "  --url-outline-color <color>      (default: #000000)"
  echo "  --url-outline-width <px>         (default: 2)"
  echo "  --url-shadow-color <color>       (default: #222222)"
  echo "  --url-shadow-offset <XxY>        (default: 2x2)"
  echo "  --url-shadow-blur <radius>       (default: 0)"
  echo "  --logo-height <px>            Logo height in pixels (default: 72)"
  echo "  --header-font <fontname>       Header font name (default: DejaVu-Sans)"
  echo "  --title-color <color>          Title (filename) text color (default: #ffffff)"
  echo "  --meta-color <color>           Metadata line text color (default: #ffffff)"
  echo "  --tagline-color <color>        Tagline text color (default: #ffffff)"
  echo "  --url-color <color>            URL text color (default: #b0c4ff)"
  echo "  -h                    Show this help message"
  exit 1
}

# --- PARSE ARGS ---
# First, handle long options and remove them from the argument list
REMAINING_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -T) TITLE_EFFECT="$2"; shift 2;;
    -E) META_EFFECT="$2"; shift 2;;
    -Q) TAGLINE_EFFECT="$2"; shift 2;;
    -W) URL_EFFECT="$2"; shift 2;;
    --title-outline-color) TITLE_OUTLINE_COLOR="$2"; shift 2;;
    --title-outline-width) TITLE_OUTLINE_WIDTH="$2"; shift 2;;
    --title-shadow-color) TITLE_SHADOW_COLOR="$2"; shift 2;;
    --title-shadow-offset) TITLE_SHADOW_OFFSET="$2"; shift 2;;
    --title-shadow-blur) TITLE_SHADOW_BLUR="$2"; shift 2;;
    --meta-outline-color) META_OUTLINE_COLOR="$2"; shift 2;;
    --meta-outline-width) META_OUTLINE_WIDTH="$2"; shift 2;;
    --meta-shadow-color) META_SHADOW_COLOR="$2"; shift 2;;
    --meta-shadow-offset) META_SHADOW_OFFSET="$2"; shift 2;;
    --meta-shadow-blur) META_SHADOW_BLUR="$2"; shift 2;;
    --tagline-outline-color) TAGLINE_OUTLINE_COLOR="$2"; shift 2;;
    --tagline-outline-width) TAGLINE_OUTLINE_WIDTH="$2"; shift 2;;
    --tagline-shadow-color) TAGLINE_SHADOW_COLOR="$2"; shift 2;;
    --tagline-shadow-offset) TAGLINE_SHADOW_OFFSET="$2"; shift 2;;
    --tagline-shadow-blur) TAGLINE_SHADOW_BLUR="$2"; shift 2;;
    --url-outline-color) URL_OUTLINE_COLOR="$2"; shift 2;;
    --url-outline-width) URL_OUTLINE_WIDTH="$2"; shift 2;;
    --url-shadow-color) URL_SHADOW_COLOR="$2"; shift 2;;
    --url-shadow-offset) URL_SHADOW_OFFSET="$2"; shift 2;;
    --url-shadow-blur) URL_SHADOW_BLUR="$2"; shift 2;;
    --logo-height) LOGO_HEIGHT_PX="$2"; shift 2;;
    --header-font) HEADER_FONT_FILE="$2"; shift 2;;
    --title-color) TITLE_COLOR="$2"; shift 2;;
    --meta-color) META_COLOR="$2"; shift 2;;
    --tagline-color) TAGLINE_COLOR="$2"; shift 2;;
    --url-color) URL_COLOR="$2"; shift 2;;
    --*) echo "Unknown option: $1"; shift 2;;
    *) REMAINING_ARGS+=("$1"); shift;;
  esac
 done
set -- "${REMAINING_ARGS[@]}"

while getopts "i:o:s:c:z:p:b:l:t:w:k:S:O:C:M:G:U:1:2:3:4:T:E:Q:W:h" opt; do
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
    C) TITLE_COLOR="$OPTARG" ;;
    M) META_COLOR="$OPTARG" ;;
    G) TAGLINE_COLOR="$OPTARG" ;;
    U) URL_COLOR="$OPTARG" ;;
    1) TITLE_SHADOW="$OPTARG" ;;
    2) META_SHADOW="$OPTARG" ;;
    3) TAGLINE_SHADOW="$OPTARG" ;;
    4) URL_SHADOW="$OPTARG" ;;
    T) TITLE_EFFECT="$OPTARG" ;;
    E) META_EFFECT="$OPTARG" ;;
    Q) TAGLINE_EFFECT="$OPTARG" ;;
    W) URL_EFFECT="$OPTARG" ;;
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

# --- FONT SIZES FOR TAGLINE AND URL (must be set before logo and tagline logic) ---
TAG_FONT=$((thumb_height/7))
URL_FONT=$((thumb_height/10))

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
# --- HEADER LAYOUT CONSTANTS ---
BRANDING_WIDTH=$((OUTW / 3))      # Rightmost 1/3 for branding
TEXT_AREA_WIDTH=$((OUTW - BRANDING_WIDTH - padding*4))
LEFT_X=$((padding*2))
RIGHT_X=$((OUTW - BRANDING_WIDTH + padding*2))

# --- FONT SIZES FOR HEADER AND METADATA (must be set before use) ---
HEADER_FONT=$((thumb_height/5))
INFO_FONT=$((thumb_height/9))
HEADER_LINE_Y=$((header_h/2 - HEADER_FONT/2 - 10))

# --- HEADER TEXT VARIABLES (must be set before use) ---
HEADER1="$BASENAME_NOEXT"
HEADER2="Codec: $CODEC | Resolution: ${WIDTH}x${HEIGHT} | Duration: ${DURATION_FMT} | Bitrate: ${BITRATE_MBPS} Mbps | FPS: ${FPS} | Audio: ${AUDIO_CODEC} | Size: ${FILESIZE_HR}"

# --- DYNAMIC TITLE FONT SCALING ---
# Allow title to go almost to the logo (leave just enough space for logo + padding)
TITLE_MAX_WIDTH=$((OUTW - LOGO_HEIGHT_PX - padding * 8))
TITLE_FONT_SIZE=$((thumb_height/5))
MIN_TITLE_FONT_SIZE=18

# Try to fit title text
CUR_FONT_SIZE=$TITLE_FONT_SIZE
while :; do
  WIDTH=$(convert -background none -fill none -font "$HEADER_FONT_FILE" -pointsize $CUR_FONT_SIZE label:"$HEADER1" -format "%w" info:)
  if [ "$WIDTH" -le "$TITLE_MAX_WIDTH" ] || [ "$CUR_FONT_SIZE" -le "$MIN_TITLE_FONT_SIZE" ]; then
    break
  fi
  CUR_FONT_SIZE=$((CUR_FONT_SIZE-2))
done
TITLE_FONT_FINAL=$CUR_FONT_SIZE

# --- DRAW TITLE (filename) LEFT, STACKED ---
HEADERED_IMG="$TMPDIR/headered.png"
if [ "$TITLE_EFFECT" = "shadow" ]; then
  convert "$TMPDIR/composite.png" \
    -fill "$TITLE_SHADOW_COLOR" -gravity NorthWest -font "$HEADER_FONT_FILE" -pointsize $TITLE_FONT_FINAL \
    -annotate +$LEFT_X+$HEADER_LINE_Y "$HEADER1" \
    $( [ "$TITLE_SHADOW_BLUR" -gt 0 ] && echo "-blur 0x$TITLE_SHADOW_BLUR" ) \
    -fill "$TITLE_COLOR" -gravity NorthWest -font "$HEADER_FONT_FILE" -pointsize $TITLE_FONT_FINAL \
    -annotate +$LEFT_X+$HEADER_LINE_Y "$HEADER1" \
    "$HEADERED_IMG"
elif [ "$TITLE_EFFECT" = "outline" ]; then
  convert "$TMPDIR/composite.png" \
    -stroke "$TITLE_OUTLINE_COLOR" -strokewidth $TITLE_OUTLINE_WIDTH -fill "$TITLE_COLOR" \
    -gravity NorthWest -font "$HEADER_FONT_FILE" -pointsize $TITLE_FONT_FINAL \
    -annotate +$LEFT_X+$HEADER_LINE_Y "$HEADER1" -stroke none \
    "$HEADERED_IMG"
else
  convert "$TMPDIR/composite.png" \
    -fill "$TITLE_COLOR" -gravity NorthWest -font "$HEADER_FONT_FILE" -pointsize $TITLE_FONT_FINAL \
    -annotate +$LEFT_X+$HEADER_LINE_Y "$HEADER1" \
    "$HEADERED_IMG"
fi

# --- DRAW METADATA LEFT, STACKED BELOW TITLE ---
HEADERED2_IMG="$TMPDIR/headered2.png"
META_Y=$((HEADER_LINE_Y + HEADER_FONT + 24))
if [ "$META_EFFECT" = "shadow" ]; then
  convert "$HEADERED_IMG" \
    -fill "$META_SHADOW_COLOR" -gravity NorthWest -pointsize $INFO_FONT \
    -annotate +$LEFT_X+$META_Y "$HEADER2" \
    $( [ "$META_SHADOW_BLUR" -gt 0 ] && echo "-blur 0x$META_SHADOW_BLUR" ) \
    -fill "$META_COLOR" -gravity NorthWest -pointsize $INFO_FONT \
    -annotate +$LEFT_X+$META_Y "$HEADER2" \
    "$HEADERED2_IMG"
elif [ "$META_EFFECT" = "outline" ]; then
  convert "$HEADERED_IMG" \
    -stroke "$META_OUTLINE_COLOR" -strokewidth $META_OUTLINE_WIDTH -fill "$META_COLOR" \
    -gravity NorthWest -pointsize $INFO_FONT \
    -annotate +$LEFT_X+$META_Y "$HEADER2" -stroke none \
    "$HEADERED2_IMG"
else
  convert "$HEADERED_IMG" \
    -fill "$META_COLOR" -gravity NorthWest -pointsize $INFO_FONT \
    -annotate +$LEFT_X+$META_Y "$HEADER2" \
    "$HEADERED2_IMG"
fi

# --- ADD LOGO, TAGLINE, URL STACKED ON RIGHT ---
LOGO="$(dirname "$0")/snap_grid_logo.png"
LOGOED_IMG="$TMPDIR/logoed.png"
LOGOPAD=$((padding*2))
LOGO_TOP_Y=$((HEADER_LINE_Y))
if [ -f "$LOGO" ]; then
  convert "$LOGO" -resize x${LOGO_HEIGHT_PX} "$TMPDIR/logo.png"
  composite -gravity NorthEast -geometry +${LOGOPAD}+$LOGO_TOP_Y "$TMPDIR/logo.png" "$HEADERED2_IMG" "$LOGOED_IMG"
else
  cp "$HEADERED2_IMG" "$LOGOED_IMG"
fi

# --- Get logo height after resize ---
if [ -f "$TMPDIR/logo.png" ]; then
  LOGO_HEIGHT=$(identify -format "%h" "$TMPDIR/logo.png")
else
  LOGO_HEIGHT=0
fi
TAGLINE_Y=$((LOGO_TOP_Y + LOGO_HEIGHT + 10))
URL_Y=$((TAGLINE_Y + TAG_FONT + 5))

# --- ADD TAGLINE STACKED BELOW LOGO ---
TAGGED_IMG="$TMPDIR/tagged.png"
if [ "$TAGLINE_EFFECT" = "shadow" ]; then
  convert "$LOGOED_IMG" \
    -fill "$TAGLINE_SHADOW_COLOR" -gravity NorthEast -pointsize $TAG_FONT \
    -annotate +$((LOGOPAD+${TAGLINE_SHADOW_OFFSET%%x*}))+$((TAGLINE_Y+${TAGLINE_SHADOW_OFFSET#*x})) "$TAGLINE" \
    $( [ "$TAGLINE_SHADOW_BLUR" -gt 0 ] && echo "-blur 0x$TAGLINE_SHADOW_BLUR" ) \
    -gravity NorthEast -fill "$TAGLINE_COLOR" -pointsize $TAG_FONT \
    -annotate +$LOGOPAD+$TAGLINE_Y "$TAGLINE" \
    "$TAGGED_IMG"
elif [ "$TAGLINE_EFFECT" = "outline" ]; then
  convert "$LOGOED_IMG" \
    -gravity NorthEast -stroke "$TAGLINE_OUTLINE_COLOR" -strokewidth $TAGLINE_OUTLINE_WIDTH \
    -fill "$TAGLINE_COLOR" -pointsize $TAG_FONT \
    -annotate +$LOGOPAD+$TAGLINE_Y "$TAGLINE" -stroke none \
    "$TAGGED_IMG"
else
  convert "$LOGOED_IMG" \
    -gravity NorthEast -fill "$TAGLINE_COLOR" -pointsize $TAG_FONT \
    -annotate +$LOGOPAD+$TAGLINE_Y "$TAGLINE" \
    "$TAGGED_IMG"
fi

# --- ADD URL STACKED BELOW TAGLINE ---
FINAL_IMG="$TMPDIR/final.png"
if [ "$URL_EFFECT" = "shadow" ]; then
  convert "$TAGGED_IMG" \
    -fill "$URL_SHADOW_COLOR" -gravity NorthEast -pointsize $URL_FONT \
    -annotate +$((LOGOPAD+${URL_SHADOW_OFFSET%%x*}))+$((${URL_Y}+${URL_SHADOW_OFFSET#*x})) "$URL" \
    $( [ "$URL_SHADOW_BLUR" -gt 0 ] && echo "-blur 0x$URL_SHADOW_BLUR" ) \
    -gravity NorthEast -fill "$URL_COLOR" -pointsize $URL_FONT \
    -annotate +$LOGOPAD+$URL_Y "$URL" \
    "$FINAL_IMG"
elif [ "$URL_EFFECT" = "outline" ]; then
  convert "$TAGGED_IMG" \
    -gravity NorthEast -stroke "$URL_OUTLINE_COLOR" -strokewidth $URL_OUTLINE_WIDTH \
    -fill "$URL_COLOR" -pointsize $URL_FONT \
    -annotate +$LOGOPAD+$URL_Y "$URL" -stroke none \
    "$FINAL_IMG"
else
  convert "$TAGGED_IMG" \
    -gravity NorthEast -fill "$URL_COLOR" -pointsize $URL_FONT \
    -annotate +$LOGOPAD+$URL_Y "$URL" \
    "$FINAL_IMG"
fi

echo "[SnapGrid] Finalizing output..."
# --- SCALE OUTPUT IF NEEDED ---
if [ "$size" != "100" ]; then
  convert "$FINAL_IMG" -resize ${size}% "$OUTPUT"
else
  cp "$FINAL_IMG" "$OUTPUT"
fi

# --- Fix possible bottom line artifact by cropping 1px if needed ---
convert "$OUTPUT" -crop x$((OUTH-1))+0+0 +repage "$OUTPUT"

echo "[SnapGrid] Done! Output saved to $OUTPUT"
