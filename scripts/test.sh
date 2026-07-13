#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/jonmoji-test.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

transparent_source="$work_dir/transparent.png"
opaque_source="$work_dir/opaque.png"
first="$work_dir/first.gif"
second="$work_dir/second.gif"

magick -size 128x128 canvas:none \
  -fill '#2D8CFF' \
  -draw 'circle 64,64 64,24' \
  "$transparent_source"

"$script_dir/render-spinner.sh" "$transparent_source" "$first" >/dev/null
"$script_dir/render-spinner.sh" "$transparent_source" "$second" >/dev/null
"$script_dir/check-output.sh" "$first" >/dev/null

if ! cmp -s "$first" "$second"; then
  echo "error: repeated renders are not byte-identical" >&2
  exit 1
fi

magick "$transparent_source" \
  -background white \
  -alpha remove \
  -alpha off \
  "$opaque_source"

if "$script_dir/render-spinner.sh" "$opaque_source" "$work_dir/invalid.gif" \
  >/dev/null 2>&1; then
  echo "error: renderer accepted a source without an alpha channel" >&2
  exit 1
fi

echo "ok: deterministic render and alpha validation"
