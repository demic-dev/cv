My CV, built with Typst ([altacv](https://typst.app/universe/package/altacv) template). The content lives in YAML files,
cv.typ renders them, and flake.nix builds the PDFs with Nix.

Files
- generic.yaml   the CV content (this is what you edit)
- cv.typ        the renderer/template (normally leave this alone)
- details.md    raw brain-dump of experience, not a CV itself
- variants/     role-tailored CVs: frontend-engineer, fullstack-engineer,
                data-engineer, data-analyst
- flake.nix     pins typst and its @preview packages, builds the PDFs

Building
Run  nix build  in this folder. It produces a result/ symlink with:
- result/resume.pdf                     the main CV
- result/resume-ATS.pdf                 single-column, ATS-friendly version
- result/variants/resume-<role>.pdf     a CV per role
- result/variants/resume-<role>-ATS.pdf ATS version per role

Run  nix develop  to get a shell with typst and the right fonts on PATH,
for manual or iterative compiles instead.

Editing content
Edit generic.yaml by hand, or add experience to details.md and run the
cv-details-parser agent (Claude Code) to write generic.yaml and the four
variants for you. The agent only rephrases what you wrote; it never invents.

Manual compile (optional)
- typst compile cv.typ out.pdf
- typst compile cv.typ out.pdf --input fileName=variants/data-analyst.yaml
- typst compile cv.typ out.pdf --input columnRatio=1
fileName picks which YAML to render (default generic.yaml); columnRatio=1
switches to the single-column ATS layout.

job-hunt-specific
A second flake package, for a job-hunt/ folder that is gitignored and so
absent from this repo. It holds one directory per application, each with
its own cv.typ and/or cover-letter.typ; the derivation compiles every one
it finds into a matching cv.pdf / cover-letter.pdf. Build it with
nix build --impure .#job-hunt-specific (--impure because job-hunt/ lives
outside the git-tracked source).
