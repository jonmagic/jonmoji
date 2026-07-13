#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 INPUT.png OUTPUT.gif" >&2
  exit 2
fi

input=$1
output=$2
max_bytes=${MAX_BYTES:-131072}
glint_centers=${GLINT_CENTERS:-}
blink_centers=${BLINK_CENTERS:-}
halo_colors=${HALO_COLORS:-'#14D9E5 #18BFEF #399AF4 #6279ED #785DE2 #6279ED #399AF4 #18BFEF'}

if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick 7 is required (missing magick)" >&2
  exit 1
fi

if [ ! -f "$input" ]; then
  echo "error: source image not found: $input" >&2
  exit 1
fi

source_alpha=$(magick identify -format '%[channels]' "$input")
case "$source_alpha" in
  *a*) ;;
  *)
    echo "error: source image must contain a real alpha channel: $input" >&2
    exit 1
    ;;
esac

output_dir=$(dirname "$output")
mkdir -p "$output_dir"

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/jonmoji.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

base="$work_dir/base.png"
halo="$work_dir/halo.png"

set -- $halo_colors
if [ "$#" -ne 8 ]; then
  echo "error: HALO_COLORS must contain exactly eight colors" >&2
  exit 1
fi

halo_1=$1
halo_2=$2
halo_3=$3
halo_4=$4
halo_5=$5
halo_6=$6
halo_7=$7
halo_8=$8

magick "$input" \
  -filter Lanczos \
  -resize 400x400 \
  -gravity center \
  -background none \
  -extent 512x512 \
  "$base"

magick -size 512x512 canvas:none \
  -fill none -strokewidth 28 \
  -stroke "$halo_1" -draw 'arc 38,38 474,474 190,220' \
  -stroke "$halo_2" -draw 'arc 38,38 474,474 235,265' \
  -stroke "$halo_3" -draw 'arc 38,38 474,474 280,310' \
  -stroke "$halo_4" -draw 'arc 38,38 474,474 325,355' \
  -stroke "$halo_5" -draw 'arc 38,38 474,474 10,40' \
  -stroke "$halo_6" -draw 'arc 38,38 474,474 55,85' \
  -stroke "$halo_7" -draw 'arc 38,38 474,474 100,130' \
  -stroke "$halo_8" -draw 'arc 38,38 474,474 145,175' \
  "$halo"

while read -r index angle glint_shift lid_inset; do
  rotated_halo="$work_dir/halo-$index.png"
  composed="$work_dir/composed-$index.png"
  frame="$work_dir/frame-$index.png"

  magick "$halo" \
    -background none \
    -gravity center \
    -rotate "$angle" \
    -extent 512x512 \
    "$rotated_halo"

  magick "$rotated_halo" "$base" \
    -gravity center \
    -compose over \
    -composite \
    "$composed"

  if [ -n "$glint_centers" ] && [ "$lid_inset" -eq 0 ]; then
    glints="$work_dir/glints-$index.png"
    magick -size 512x512 canvas:none "$glints"

    for center in $glint_centers; do
      center_x=${center%,*}
      center_y=${center#*,}
      glint_x=$((center_x + glint_shift))

      magick "$glints" \
        -fill none \
        -stroke 'rgba(225,255,255,0.82)' \
        -strokewidth 8 \
        -draw "line $((glint_x - 6)),$((center_y + 9)) $((glint_x + 6)),$((center_y - 9))" \
        "$glints"
    done

    magick "$composed" "$glints" \
      -gravity center \
      -compose over \
      -composite \
      "$composed"
  fi

  if [ "$lid_inset" -gt 0 ] && [ -n "$blink_centers" ]; then
    blink_overlay="$work_dir/blink-$index.png"
    magick -size 512x512 canvas:none "$blink_overlay"

    for center in $blink_centers; do
      center_x=${center%,*}
      center_y=${center#*,}
      if [ "$center_x" -lt 256 ]; then
        sample_x=$((center_x + 28))
      else
        sample_x=$((center_x - 28))
      fi
      top_color=$(magick "$base" \
        -format "%[pixel:p{$sample_x,$((center_y - 24))}]" \
        info:)
      bottom_color=$(magick "$base" \
        -format "%[pixel:p{$sample_x,$((center_y + 24))}]" \
        info:)

      eye_lids="$work_dir/eye-lids-$index-$center_x.png"
      eye_mask="$work_dir/eye-mask-$index-$center_x.png"
      clipped_lids="$work_dir/clipped-lids-$index-$center_x.png"

      magick -size 512x512 canvas:none \
        -stroke none \
        -fill "$top_color" \
        -draw "roundrectangle $((center_x - 20)),$((center_y - 30)) $((center_x + 20)),$((center_y - 30 + lid_inset)) 6,6" \
        -fill "$bottom_color" \
        -draw "roundrectangle $((center_x - 20)),$((center_y + 30 - lid_inset)) $((center_x + 20)),$((center_y + 30)) 6,6" \
        "$eye_lids"

      magick -size 512x512 canvas:none \
        -fill white \
        -stroke none \
        -draw "ellipse $center_x,$center_y 16,27 0,360" \
        "$eye_mask"

      magick "$eye_lids" "$eye_mask" \
        -compose DstIn \
        -composite \
        "$clipped_lids"

      magick "$blink_overlay" "$clipped_lids" \
        -compose over \
        -composite \
        "$blink_overlay"
    done

    magick "$composed" "$blink_overlay" \
      -gravity center \
      -compose over \
      -composite \
      "$composed"
  fi

  magick "$composed" \
    -filter Lanczos \
    -resize 128x128 \
    -channel A -threshold 50% +channel \
    -strip \
    "$frame"
done <<'FRAMES'
00   0   0  0
01  30   5  0
02  60   9  0
03  90  10  0
04 120   9  8
05 150   5 14
06 180   0  8
07 210  -5  0
08 240  -9  0
09 270 -10  0
10 300  -9  0
11 330  -5  0
FRAMES

candidate="$work_dir/candidate.gif"
created=false

for colors in 128 96 64 48; do
  magick -delay 12 -dispose previous "$work_dir"/frame-*.png \
    -loop 0 \
    -colors "$colors" \
    -layers OptimizeTransparency \
    "$candidate"

  bytes=$(wc -c <"$candidate" | tr -d ' ')
  if [ "$bytes" -le "$max_bytes" ]; then
    mv "$candidate" "$output"
    created=true
    break
  fi
done

if [ "$created" != true ]; then
  echo "error: unable to render GIF within $max_bytes bytes" >&2
  exit 1
fi

preview="${output%.*}-preview.png"
cp "$work_dir/frame-00.png" "$preview"

echo "rendered: $output"
echo "preview:  $preview"
