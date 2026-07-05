---
name: variants
description: The four role-tailored CV variants in variants/, their target roles, and how each is tailored by selection/reordering only
metadata:
  type: project
---

Four role-tailored CVs live in `/home/michele/repos/cv/variants/`, each a complete standalone
JSON-Resume YAML using the EXACT same schema as `resume.yaml` (see [[resume-schema]]) so `cv.typ`
renders any of them by swapping input. Do NOT modify `cv.typ`.

- `frontend-engineer.yaml` — label "Front-End Engineer". Work order: Pane&Design, Online Impresa,
  Polyneta, NERDS. Projects: Open Source, Homelab, ALS.
- `fullstack-engineer.yaml` — label "Full-Stack Engineer". Work order: Online Impresa, Pane&Design,
  Polyneta, NERDS. Projects: Open Source, Homelab, ALS.
- `data-engineer.yaml` — label "Data Engineer". Work order: NERDS, Polyneta, Online Impresa,
  Pane&Design (NERDS lead highlight = HPC pipeline; Polyneta lead = scraping/RAG/OCR pipeline).
  Projects: ALS, Homelab, Open Source (nixpkgs lead).
- `data-analyst.yaml` — label "Data Analyst". Work order: NERDS, Polyneta, Pane&Design, Online
  Impresa (NERDS lead = Magnetic Laplacian + validation; Polyneta lead = customer discovery/market
  research). Projects: ALS, Open Source, Homelab.

**Tailoring conventions (established 2026-07-05, user asked to go beyond just reorder+label):**
- Tailoring = SELECTION + REORDERING + EMPHASIS + role-appropriate REWORDING. Levers used:
  `basics.label`, order of `work` entries, order + REWORDING of highlights, moderate TRIMMING of
  off-target highlights, order of `projects`, and reordered + role-augmented `skills` keywords.
- `basics.summary` is kept COMMENTED in every variant (user explicitly said do NOT enable), matching
  `resume.yaml`'s rendered state; the commented text is role-tailored so it can be enabled later.
- REWORDING rule: same facts, role-appropriate framing — wording changes, claims never do. Examples
  applied: Online Impresa deployment-automation bullet is "build tooling / pipeline" framed for
  data-eng vs. "shipped to the stores" for fullstack; the closed-order dashboard is framed as
  "internal reporting" for data roles; NERDS Reddit pipeline foregrounds ETL for data-eng and data
  prep for data-analyst. Do NOT introduce words that overstate (e.g. avoided "shipped the alpha" —
  details.md only says the alpha was "developed").
- SKILL CHIPS added per-variant from details.md (NOT in canonical, do not touch resume.yaml):
  Tailwind + styled-components + Material UI on frontend & fullstack; Pandas on data-eng &
  data-analyst. These are user-approved per-variant additions.
- TRIM level = MODERATE: shorten least-relevant entries to ~2 highlights, drop a few off-target
  bullets, but never drop a whole job. Star (most-relevant) entry per role keeps ~4 highlights.
- `education`, `awards`, `languages`, `certificates` are identical across all variants and canonical.

**Keep in sync:** any fact removed/corrected in details.md/resume.yaml must propagate to all four
variants. Data-engineer and data-analyst source material is thinner (most work history is
frontend/full-stack); flag this rather than padding.
