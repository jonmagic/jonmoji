# jonmoji

Create consistent, reusable animated emoji from transparent source artwork using deterministic local rendering workflows.

jonmoji keeps source artwork stable and animates controlled overlays such as
spinners, highlights, and status indicators. This avoids the visual drift that
comes from generating every animation frame independently.

## Requirements

- ImageMagick 7 (`magick`)
- ffmpeg for optional inspection and future video formats
- POSIX shell

No package manager or third-party language dependencies are required.

## Copilot review emoji

Place the transparent Copilot source image at `assets/copilot.png`, then run:

```sh
make render
make check
make test
```

The generated files are:

- `dist/copilot-review.gif`
- `dist/copilot-review-preview.png`

The renderer creates 12 distinct frames at 128x128. The mascot remains static
while a hard-edged segmented halo rotates behind it and small highlights scan
across the lenses. Hard edges are intentional because GIF transparency is
binary and Slack can display emoji against both light and dark backgrounds.

## Reusing the renderer

The generic renderer accepts any transparent PNG:

```sh
scripts/render-spinner.sh source.png output.gif
```

Optional lens or eye highlights are supplied as space-separated coordinates on
the 512x512 working canvas:

```sh
GLINT_CENTERS="188,202 320,202" \
  scripts/render-spinner.sh source.png output.gif
```

Blink centers use coordinates on the 512x512 working canvas. The renderer
creates a short close-and-open motion while preserving a narrowing strip of the
original eye pixels:

```sh
BLINK_CENTERS="220,312 293,312" \
  scripts/render-spinner.sh source.png output.gif
```

Override the eight halo segment colors when an asset needs a different palette:

```sh
HALO_COLORS="#FFB000 #FF8A00 #FF6400 #FF3B30 #E6358A #B43AE2 #7657E8 #3D7BFA" \
  scripts/render-spinner.sh source.png output.gif
```

Render at 512x512 for clean interior shapes, but judge the result at roughly
28x28 because that is close to its displayed size in chat.

Source artwork may carry separate trademark or redistribution restrictions.
Source assets are intentionally ignored by Git and are not included in the
public repository. Do not publish an asset or generated emoji unless its use
is authorized.

## License

Jonmoji's source code and documentation are available under the ISC License.
Source artwork supplied by users is not included or licensed by this project.
