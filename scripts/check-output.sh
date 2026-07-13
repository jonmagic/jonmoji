#!/bin/sh

set -eu

file=${1:-dist/copilot-review.gif}
expected_size=${EXPECTED_SIZE:-128x128}
expected_frames=${EXPECTED_FRAMES:-12}
max_bytes=${MAX_BYTES:-131072}

if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick 7 is required (missing magick)" >&2
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "error: output not found: $file" >&2
  exit 1
fi

formats=$(magick identify -format '%m\n' "$file" | sort -u)
dimensions=$(magick identify -format '%wx%h\n' "$file" | sort -u)
frames=$(magick identify "$file" | wc -l | tr -d ' ')
bytes=$(wc -c <"$file" | tr -d ' ')
iterations=$(magick identify -verbose "$file" |
  awk -F': ' '/Iterations:/{print $2; exit}')

if [ "$formats" != "GIF" ]; then
  echo "error: expected GIF, got: $formats" >&2
  exit 1
fi

if [ "$dimensions" != "$expected_size" ]; then
  echo "error: expected dimensions $expected_size, got: $dimensions" >&2
  exit 1
fi

if [ "$frames" -ne "$expected_frames" ]; then
  echo "error: expected $expected_frames frames, got: $frames" >&2
  exit 1
fi

if [ "$bytes" -gt "$max_bytes" ]; then
  echo "error: expected at most $max_bytes bytes, got: $bytes" >&2
  exit 1
fi

if [ -z "$iterations" ]; then
  echo "error: GIF loop metadata was not found" >&2
  exit 1
fi

if [ "$iterations" -ne 0 ]; then
  echo "error: expected an infinite loop, got iterations=$iterations" >&2
  exit 1
fi

echo "ok: $file"
echo "    dimensions: $dimensions"
echo "    frames:     $frames"
echo "    bytes:      $bytes"
echo "    iterations: $iterations"
