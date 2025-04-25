#!/bin/bash
# daily-uploader.sh: Automate SnapGrid, imgbb, gofile, and buzzheavier uploads for videos

# Extra safety for filenames with spaces/special chars
IFS=$'\n\t'
set -f  # Disable globbing

# --- CONFIGURABLE ---
SNAPGRID_PATH="./snapgrid.sh"  # Change to your SnapGrid location or ensure in PATH
IMGBB_API="https://api.imgbb.com/1/upload"
GOFILE_API="https://api.gofile.io/uploadFile"
BUZZHEAVIER_API="https://buzzheavier.com/upload"

# === Configurable Buzzheavier Location ===
# Default: Eastern US (id=12brteedoy0f). Other options:
# Central Europe: 3eb9t1559lkv
# Western US: 95542dt0et21
BUZZHEAVIER_LOCATION_ID="12brteedoy0f"

# --- IMGBB API KEY ---
# Option 1: Set as environment variable before running: export IMGBB_API_KEY=your_key
# Option 2: Set here:
IMGBB_API_KEY="${IMGBB_API_KEY:-}"  # Use env var if set, else blank

# --- FUNCTIONS ---
usage() {
  echo "Usage: $0 [-o output.txt] <file1> [file2 ...] | <directory>"
  exit 1
}

# Check dependencies
for dep in curl jq; do
  command -v $dep >/dev/null 2>&1 || { echo "$dep is required. Please install it."; exit 1; }
done

# Find SnapGrid
if ! command -v snapgrid.sh >/dev/null 2>&1 && [ ! -x "$SNAPGRID_PATH" ]; then
  echo "SnapGrid not found. Please place snapgrid.sh in the same directory or in your PATH."; exit 1
fi

# Parse args
OUTPUT_FILE=""
FILES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      OUTPUT_FILE="$2"; shift 2;;
    -h|--help)
      usage;;
    *)
      FILES+=("$1"); shift;;
  esac
done

if [ ${#FILES[@]} -eq 0 ]; then
  usage
fi

# Expand directory if needed
INPUTS=()
for f in "${FILES[@]}"; do
  if [ -d "$f" ]; then
    while IFS= read -r -d $'\0' file; do
      INPUTS+=("$file")
    done < <(find "$f" -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.avi' -o -iname '*.mov' -o -iname '*.webm' -o -iname '*.*' \) -print0)
  else
    INPUTS+=("$f")
  fi
done

# Prompt for imgbb API key if not set
if [ -z "$IMGBB_API_KEY" ]; then
  read -rp "Enter your imgbb API key: " IMGBB_API_KEY
fi

# Main processing
RESULTS=""
for vid in "${INPUTS[@]}"; do
  [ -f "$vid" ] || continue
  fname=$(basename "$vid")
  base="${vid%.*}"
  png="${base}.png"
  fname_noext="${fname%.*}"
  ext="${vid##*.}"
  ext_lc="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"

  echo "\n==== Processing: $fname ===="

  # Determine if file is a video type
  is_video=0
  case "$ext_lc" in
    mp4|mkv|avi|mov|webm)
      is_video=1
      ;;
  esac

  # --- Use safe temp filename for upload ---
  safe_vid="upload-$$.$ext_lc"
  cp -- "$vid" "$safe_vid"

  if [ "$is_video" -eq 1 ]; then
    # 1. Run SnapGrid
    echo "[STATUS] Running SnapGrid for $fname..."
    if [ ! -f "$png" ]; then
      if command -v snapgrid.sh >/dev/null 2>&1; then
        snapgrid.sh -i "$vid" -o "$png"
      else
        "$SNAPGRID_PATH" -i "$vid" -o "$png"
      fi
    fi
    # Use safe temp png for upload
    safe_png="upload-$$.png"
    cp -- "$png" "$safe_png"
    # 2. Upload PNG to imgbb
    echo "[STATUS] Uploading PNG to imgbb for $fname..."
    imgbb_response=$(curl -s -w '\nHTTP_STATUS:%{http_code}' -F "image=@$safe_png" "$IMGBB_API?expiration=0&key=$IMGBB_API_KEY")
    imgbb_json=$(echo "$imgbb_response" | sed '/HTTP_STATUS:/d')
    imgbb_status_code=$(echo "$imgbb_response" | grep 'HTTP_STATUS:' | cut -d: -f2)
    echo "[IMGBB RAW RESPONSE] $imgbb_response" >&2
    imgbb_success=$(echo "$imgbb_json" | jq -r '.success')
    if [ "$imgbb_success" != "true" ]; then
      echo "[ERROR] imgbb upload failed. Status code: $imgbb_status_code. Response: $imgbb_json" >&2
      bbcode="[IMGBB UPLOAD FAILED]"
    else
      imgbb_url=$(echo "$imgbb_json" | jq -r '.data.url_viewer')
      imgbb_img=$(echo "$imgbb_json" | jq -r '.data.display_url')
      bbcode="[url=$imgbb_url][img]$imgbb_img[/img][/url]"
    fi
  fi

  # 3. Upload file to gofile (anonymous session, matches upload-rs)
  echo "[STATUS] Creating anonymous gofile session..."
  gofile_account_json=$(curl -s -X POST "https://api.gofile.io/accounts")
  echo "[GOFILE ACCOUNT RAW RESPONSE] $gofile_account_json" >&2
  gofile_token=$(echo "$gofile_account_json" | jq -r '.data.token')
  gofile_root_folder=$(echo "$gofile_account_json" | jq -r '.data.rootFolder')

  echo "[STATUS] Fetching gofile server..."
  gofile_servers_json=$(curl -s "https://api.gofile.io/servers")
  echo "[GOFILE SERVERS RAW RESPONSE] $gofile_servers_json" >&2
  gofile_server=$(echo "$gofile_servers_json" | jq -r '.data.servers[0].name')

  echo "[STATUS] Creating gofile folder..."
  gofile_folder_json=$(curl -s -X POST -H "Authorization: Bearer $gofile_token" -H "Referer: https://gofile.io/" -H "Content-Type: application/json" \
    -d '{"parentFolderId":"'$gofile_root_folder'"}' "https://api.gofile.io/contents/createfolder")
  echo "[GOFILE CREATE FOLDER RAW RESPONSE] $gofile_folder_json" >&2
  gofile_folder_id=$(echo "$gofile_folder_json" | jq -r '.data.id')

  # Set folder to public
  echo "[STATUS] Setting gofile folder to public..."
  gofile_public_json=$(curl -s -X PUT -H "Authorization: Bearer $gofile_token" -H "Referer: https://gofile.io/" -H "Content-Type: application/json" \
    -d '{"attribute":"public","attributeValue":"true"}' "https://api.gofile.io/contents/$gofile_folder_id/update")
  echo "[GOFILE SET PUBLIC RAW RESPONSE] $gofile_public_json" >&2

  echo "[STATUS] Uploading file to gofile for $fname..."
  gofile_upload_url="https://$gofile_server.gofile.io/contents/uploadFile"
  gofile_upload_json=$(curl -s -X POST -H "Authorization: Bearer $gofile_token" -H "Referer: https://gofile.io/" \
    -F "file=@$safe_vid" -F "folderId=$gofile_folder_id" "$gofile_upload_url")
  echo "[GOFILE UPLOAD RAW RESPONSE] $gofile_upload_json" >&2
  gofile_status=$(echo "$gofile_upload_json" | jq -r '.status')
  if [ "$gofile_status" != "ok" ]; then
    echo "[ERROR] gofile upload failed. Response: $gofile_upload_json" >&2
    gofile_link="[GOFILE UPLOAD FAILED]"
  else
    gofile_link=$(echo "$gofile_upload_json" | jq -r '.data.downloadPage')
  fi

  # 4. Upload file to buzzheavier (PUT to w.buzzheavier.com/{filename}?locationId=...)
  echo "[STATUS] Uploading file to buzzheavier for $fname..."
  buzz_url="https://w.buzzheavier.com/$(basename "$safe_vid")?locationId=$BUZZHEAVIER_LOCATION_ID"
  buzz_response=$(curl -s -T "$safe_vid" "$buzz_url")
  echo "[BUZZHEAVIER RESPONSE] ${buzz_response:0:500}" >&2
  if echo "$buzz_response" | grep -qi 'error\|denied\|fail'; then
    echo "[ERROR] buzzheavier upload failed. Response: $buzz_response" >&2
    buzz_link="[BUZZHEAVIER UPLOAD FAILED]"
  elif echo "$buzz_response" | grep -q '"id"'; then
    buzz_id=$(echo "$buzz_response" | jq -r '.data.id')
    if [ "$buzz_id" != "null" ] && [ -n "$buzz_id" ]; then
      buzz_link="https://buzzheavier.com/$buzz_id"
    else
      buzz_link="[BUZZHEAVIER UNKNOWN RESPONSE]"
    fi
  else
    buzz_link="[BUZZHEAVIER UNKNOWN RESPONSE]"
  fi

  # 5. Gather output for final section only
  if [ "$is_video" -eq 1 ]; then
    out="${bbcode}\n${fname_noext}\n${gofile_link}\n${buzz_link}\n"
  else
    out="${fname_noext}\n${gofile_link}\n${buzz_link}\n"
  fi
  RESULTS+="$out\n"

  # --- Clean up temp files ---
  rm -f -- "$safe_vid"
  if [ "$is_video" -eq 1 ]; then rm -f -- "$safe_png"; fi
done

# Save to file if requested
if [ -n "$OUTPUT_FILE" ]; then
  echo -e "$RESULTS" > "$OUTPUT_FILE"
  echo "Results saved to $OUTPUT_FILE"
fi

# === FINAL OUTPUT ===
echo -e "\n\n==== FINAL RESULTS ===="
echo -e "$RESULTS"

exit 0
