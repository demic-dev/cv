---
name: confirmed-facts
description: Anonymization and source-of-truth conventions for the CV (brand names hidden, details.md authoritative)
metadata:
  type: project
---

Facts and conventions confirmed for Michele's CV:

- **Brand anonymization:** In `details.md`, client brands are written as placeholders (`brand1`..`brand4`).
  These are intentionally anonymized — never invent real brand names. Describe them generically in the CV
  (e.g. "a Fortune 500 client's high-traffic e-commerce site (~100k monthly visits, SEMrush estimate)").
- **details.md is authoritative** over `cv.typ` when values conflict. Known conflicts as of 2026-07:
  Online Impresa deployment time is "~1 hour to ~15 minutes" in details.md (cv.typ says "45 to 10");
  Ghost Blog stars are "+54k" in details.md (older resume.yaml said "+50k").
- **Dates already resolved in resume.yaml** (more precise than details.md's rough ranges):
  Online Impresa 2020-07/2021-09, Pane&Design 2021-10/2022-12. details.md lists both as "2020-2022".
- **Confirmed metrics (from user, 2026-07-03):** NERDS toy-network validation reached an *average
  correlation of 0.65* (now in the CV). Pane&Design worked on further high-traffic sites up to *~200k
  monthly visits* (details.md brand3 ~100k, brand4 ~200k). Polyneta `url` corrected by user to
  `https://polyneta.netlify.app/`.
- **University Startup Challenge** added as an `awards` entry (First Place, 2025, team of 4 → became
  Polyneta). Only details.md-supported facts used. NOTE: `cv.typ` additionally claims "400 participants",
  "among all Milan universities", "awarded startup incubation", and date "May 2025" — these are NOT in
  details.md and are unverified; do not add them to resume.yaml without user confirmation.
- **Thesis link (resolved 2026-07-03):** user added an inline `#link(...)` to the NERDS grade highlight
  pointing to their thesis raw file on GitHub. Inline Typst `#link("url")[label]` in a highlight works
  because these fields go through eval markup — this is the confirmed pattern for hyperlinks in bullets.
- **"Accomplishments" section (decided 2026-07-03):** the `awards` section holds non-award accomplishments
  too. Heading was renamed Awards → "Accomplishments" via a `labels` override on the `alta` call in
  `cv.typ`: `#alta-from-yaml("resume.yaml", labels: (awards: "Accomplishments"), preferences: (...))`.
  altacv section-heading labels are overridable this way (key names mirror JSON-Resume section keys);
  no package edit needed. Now contains: Top-Percentile Academic Ranking + University Startup Challenge
  (First Place) + Silicon Valley Study Tour (2025-08, no awarder — it's a selection, not an award).
  SVST facts pulled only from details.md.
- **Academic ranking accomplishment (added 2026-07-03):** top 20% for academic performance and top 15%
  for graduation grade (University of Milan), each hyperlinked to its official unimi.it PDF source cited
  in details.md. Degree grade 103/110 is in details.md but not shown in this entry.
