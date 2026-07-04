---
name: markup-conventions
description: Free-text CV fields render through Typst eval — use *bold* / _italic_ / `code`, never markdown-style ** bold
metadata:
  type: feedback
---

In `resume.yaml`, the free-text fields — `basics.summary`, `work.summary`, `work.highlights`,
`projects.description`, `projects.highlights` (and volunteer/awards/publications/references) — are
run through Typst `eval(mode: "markup")` by `cv.typ`. All other fields (names, dates, urls) pass
through literally.

**Why:** Typst markup differs from Markdown. In Typst: `*text*` = **bold**, `_text_` = italic,
`` `text` `` = monospace/raw, `#link("url")[label]` = link. Markdown-style `**text**` does NOT bold
in Typst (the `*` are strong-toggles, so `**x**` renders as empty-bold + x + empty-bold). The
existing file already uses this: `*perceived 50%*` (bold metric), `_90% accuracy_` (italic),
`` `Pixelfed` `` (monospace repo name).

**How to apply:** When applying the X/Y/Z highlight template, express the "bold" emphasis with a
single asterisk `*...*`, not `**...**`. Wrap key metrics in `*...*` or `_..._`; wrap repo/project
proper names in backticks (projects section convention). Work-section highlights currently keep tech
names plain (no backticks). Use YAML folded block scalars (`- >-`) for any summary/highlight that
contains a colon+space (e.g. "Stack: Python"), `*`, or `~`, to avoid YAML parse issues.

**Hyperlinks in free-text fields:** use inline `#link("url")[label]`. `cv.typ`'s `_eval-markup`
wraps eval'd content in a scoped `#show link: underline`, so links in bullets/descriptions/summaries
render **underlined** automatically (user preference, 2026-07-03) — do NOT hand-wrap them in
`#underline(...)`. Header/section-title links are outside this path and keep altacv's default style.
IMPORTANT: in a folded scalar (`>-`) keep each `#link("...")[..]` on a single physical line, or the
fold inserts a space into the URL and breaks it.

**Single-column layout (`cv.typ`):** `columnRatio` is a `#let` at the bottom of `cv.typ`. Custom
`leftColumnSections`/`rightColumnSections` are guarded to apply ONLY when `columnRatio == 1` (altacv
concatenates left+right in order for single column); two-column mode falls back to altacv defaults.
Section-key names must be valid altacv keys (e.g. `publications`, not `pubblications`) or
`validate-column` panics.
