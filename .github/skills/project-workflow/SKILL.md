---
name: project-workflow
description: Create and validate deterministic animated emoji in jonmoji. Use for "create an emoji", "animate this icon", "render a spinner emoji", or adding a reusable animation preset. Do not use for unrelated image editing.
---

# jonmoji Project Workflow

Use this skill to turn transparent source artwork into a small, consistent
animated emoji without regenerating the character in each frame.

## Workflow

1. Read `AGENTS.md` and any relevant local docs.
2. Check `git status --short`.
3. Confirm the source has a real alpha channel rather than a baked checkerboard.
4. Keep the source artwork static and animate separate deterministic overlays.
5. Put reusable behavior in `render-spinner.sh` and asset geometry in a preset wrapper.
6. Render at 512x512, downsample to 128x128, and threshold the outer alpha edge.
7. Run `make check` and inspect the GIF near its actual chat display size.
8. Improve the harness when a rendering or optimization failure reveals a durable constraint.

## Quality Loop

1. Preserve exact frame alignment and source proportions.
2. Use only distinct loop frames; do not repeat frame zero at the end.
3. Prefer flat colors and hard-edged transparency for GIF output.
4. Keep generated GIFs at 128x128 and within the configured byte budget.
5. Do not publish source artwork without confirming redistribution rights.

## ZShot Visual Checks

Use ZShot when browser rendering, visual state, or captured page artifacts would improve confidence. Default command path on jonmagic's Mac: `~/Library/Application Support/ZShot/zshot`.

1. Start with `zshot --agent-help` when unsure.
2. Prefer HTML/MHTML smoke captures when license support for screenshots or PDFs is unavailable.
3. Put temporary outputs under `zshot-artifacts/` or another ignored path.
4. Do not capture secrets or sensitive private pages unless the user explicitly approves the local-only artifact.

## Do Not Use For

- Generating unrelated illustrations.
- Asking an image model to produce a complete animation sprite sheet.
- One-off image conversion with no animation or reusable workflow.
