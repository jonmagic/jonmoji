# Jonmoji Agent Guide

These instructions apply to the whole repository unless a deeper `AGENTS.md` overrides them. The closest `AGENTS.md` wins.

## Mission

Create consistent, reusable animated emoji from transparent source artwork using deterministic local rendering workflows.

## Start Here

1. Read `README.md` and the nearest `AGENTS.md` before making changes.
2. Check `git status --short` before editing.
3. Preserve user edits. Never reset, checkout, or overwrite dirty files unless explicitly asked.
4. Prefer project skills in `.github/skills/` for reusable workflows and domain guidance.

## Non-negotiables

1. Do not estimate timelines unless the user explicitly asks.
2. Use red-green-refactor wherever practical.
3. Keep docs close to behavior and update them in the same slice.
4. Ask before destructive or irreversible changes, adding secrets, widening privileges, publishing, purchasing, or making external side effects.
5. Prefer quality over speed. Use critical review for changes with meaningful security, privacy, data-handling, architecture, production, or product-risk consequences.

## Development Harness

Tooling: Shell, ImageMagick, and ffmpeg; no package manager

Use these commands:

```sh
make render
make check
make test
make clean
```

Do not add a package manager or dependency for image transformations that
ImageMagick or ffmpeg already supports.

## ZShot Visual Harness

Use ZShot for browser-backed captures when visual output, rendered HTML, page state, diagnostics, or agent-readable snapshots would improve confidence. On jonmagic's Mac, the bundled CLI is usually available at `~/Library/Application Support/ZShot/zshot`; discover capabilities with `zshot --agent-help`, `zshot --help`, and `zshot --help all`.

Recommended default checks:

1. Capture rendered HTML for low-friction smoke checks: `zshot -t html -f zshot-artifacts/<name>.html <url>`.
2. Use screenshots, PDF, HAR, WARC, Markdown, AXTree, trace, or pprof only when the local license supports the output type.
3. Keep generated ZShot artifacts out of commits unless they are intentional fixtures or documentation assets.
4. Do not send secrets, private app data, or sensitive URLs through third-party services for capture.

## Architecture and Boundaries

- `assets/` contains user-provided transparent source artwork.
- `scripts/render-spinner.sh` is the asset-agnostic animation pipeline and
  provides a configurable default halo palette.
- Asset-specific wrappers such as `scripts/render-copilot-review.sh` contain
  coordinates and visual choices tied to one source image.
- `scripts/check-output.sh` enforces structural output requirements.
- `dist/` contains generated artifacts and is not source.

Render intermediate frames in a temporary directory and clean them on exit.
GIF has binary transparency, so effects touching transparent edges must use
hard-edged opaque shapes rather than soft glows. Render 12 distinct angles from
0 through 330 degrees; never duplicate the first frame at 360 degrees.

Keep the pipeline local and deterministic. Do not use generative image models
to create individual frames.

## Agent Workflow

- Make focused, reviewable slices.
- Use direct tools for bounded search, reads, and small edits.
- Add or update project skills only when repeated workflows justify a routing-friendly skill.
- Use red-green-refactor where practical: write or identify the failing expectation first, make the smallest working change, then clean up while preserving behavior.
- Rubber-duck high-stakes or ambiguous work before treating the direction as settled, especially around security, privacy, data handling, external services, persistence, deployment, permissions, or broad architecture.
- If an agent miss happens, improve the durable harness with the smallest useful artifact: instructions, docs, scripts, tests, or guardrails.
- Leave the repo easier for the next agent: capture newly discovered commands, constraints, validation steps, and project-specific gotchas in the closest durable file.

## Task Exit Criteria

1. Closest available validation passes.
2. Behavior is verified automatically or manually.
3. Documentation is updated when commands, behavior, workflow, or constraints change.
4. Handoff names changed files and remaining risks.

## Ask First

Ask before:

- touching broad or unrelated areas of the repo
- introducing a new framework, background worker, MCP server, queue, or sub-agent layer
- changing persistence, permissions, authentication, authorization, billing, or deployment behavior
- committing or pushing if the user has not asked for it in this project
