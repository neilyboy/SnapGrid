#!/bin/bash
# SnapGrid Theme: Moon Phases
# Modern cool tones with subtle shadows and outlines
# Usage: ./moon_phases_theme.sh <inputfile> [outputfile]

# --- Theme Colors ---
COLOR1="#212A31"    # Main background
COLOR2="#2E3944"    # Secondary background
GRID_COLOR="#124E66" # Grid border
TITLE_COLOR="#D3D9D4" # Title text
META_COLOR="#748D92"  # Metadata text
TAGLINE_COLOR="#D3D9D4" # Tagline text
URL_COLOR="#D3D9D4"     # URL text

# --- Shadow & Outline ---
TITLE_EFFECT="shadow"
TITLE_SHADOW_COLOR="#748D92"
TITLE_SHADOW_BLUR=2
TITLE_OUTLINE_COLOR="#124E66"
TITLE_OUTLINE_WIDTH=2

# --- Other Options ---
LOGO_HEIGHT_PX=64
HEADER_FONT_FILE="DejaVu-Sans"

# --- Input/Output ---
INPUT="$1"
OUTPUT="$2"
if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 <inputfile> [outputfile]"
  exit 1
fi
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${INPUT%.*}_moonphases.png"
fi

# --- Call snapgrid.sh with theme options ---
DIR="$(dirname "$0")"
"$DIR/snapgrid.sh" -i "$INPUT" -o "$OUTPUT" \
  -C "$COLOR1" -M "$META_COLOR" -G "$GRID_COLOR" -U "$URL_COLOR" \
  -T "$TITLE_EFFECT" -E outline -Q none -W shadow \
  --title-color "$TITLE_COLOR" --tagline-color "$TAGLINE_COLOR" \
  --logo-height "$LOGO_HEIGHT_PX" --header-font "$HEADER_FONT_FILE" \
  --title-shadow-color "$TITLE_SHADOW_COLOR" --title-shadow-blur "$TITLE_SHADOW_BLUR" \
  --title-outline-color "$TITLE_OUTLINE_COLOR" --title-outline-width "$TITLE_OUTLINE_WIDTH"
