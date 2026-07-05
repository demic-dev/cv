CV

My CV, built with Typst (altacv template). The content lives in YAML files,
cv.typ renders them, and shell.nix compiles the PDFs.

Files
- resume.yaml   the CV content (this is what you edit)
- cv.typ        the renderer/template (normally leave this alone)
- details.md    raw brain-dump of experience, not a CV itself
- variants/     role-tailored CVs: frontend-engineer, fullstack-engineer,
                data-engineer, data-analyst
- shell.nix     dev shell that compiles everything when you enter it

Building
Run  nix-shell  in this folder. It compiles what changed and exits, producing:
- cv.pdf                                the main CV
- cv-ATSREADY.pdf                       single-column, ATS-friendly version
- variants/<role>_cv.pdf                a CV per role
- variants/<role>_cv-ATSREADY.pdf       ATS version per role

Editing content
Edit resume.yaml by hand, or add experience to details.md and run the
cv-details-parser agent (Claude Code) to write resume.yaml and the four
variants for you. The agent only rephrases what you wrote; it never invents.

Manual compile (optional)
- typst compile cv.typ out.pdf
- typst compile cv.typ out.pdf --input fileName=variants/data-analyst.yaml
- typst compile cv.typ out.pdf --input columnRatio=1
fileName picks which YAML to render (default resume.yaml); columnRatio=1
switches to the single-column ATS layout.
