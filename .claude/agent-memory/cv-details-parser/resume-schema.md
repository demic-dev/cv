---
name: resume-schema
description: The CV lives in resume.yaml (JSON-Resume schema), rendered to PDF by cv.typ via the altacv Typst package
metadata:
  type: project
---

The user's CV source of record is `/home/michele/repos/cv/resume.yaml`, written in the
**JSON-Resume schema** but as YAML. The raw experience dump is `/home/michele/repos/cv/details.md`.

**Why:** `resume.yaml` is rendered to PDF by `/home/michele/repos/cv/cv.typ`, which uses the
`altacv` Typst package via a helper `alta-from-yaml`. There is also an older `cv.typ` (basic-resume
package) with hand-written content — it is a separate, parallel artifact and can drift from
resume.yaml (e.g. different metric values). When translating details.md, `resume.yaml` is the target
and `details.md` is authoritative over `cv.typ`.

**How to apply:** Edit `resume.yaml` for CV updates. Preserve the JSON-Resume field names/nesting:
`basics`, `work` (name, position, url, location, startDate "YYYY-MM", endDate, summary, highlights),
`projects` (name, startDate, description OR highlights, url), `education`, `certificates`, `skills`,
`languages`. See [[markup-conventions]] for how free-text fields render.
