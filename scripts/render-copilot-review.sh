#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
project_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

GLINT_CENTERS='188,202 320,202'
BLINK_CENTERS='220,312 293,312'
export GLINT_CENTERS BLINK_CENTERS

exec "$script_dir/render-spinner.sh" \
  "$project_dir/assets/copilot.png" \
  "$project_dir/dist/copilot-review.gif"
