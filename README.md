# CV

My CV and cover letters. The content lives in YAML files, Typst renders them, and Nix builds the PDFs. The CV template is a Typst port of
[Jake's Resume](https://github.com/jakegut/resume); the cover letter follows the same look.

## Layout

```
    cv.typ                 entry point for a CV: reads a YAML file, renders it
    cover-letter.typ       entry point for a cover letter, same idea
    templates/cv.typ       the CV template (`jake`), ported from the LaTeX original
    templates/cover-letter.typ  the letter template
    inputs/info.yaml       the CV content, and the default input of cv.typ
    inputs/letter.yaml     a letter, and the default input of cover-letter.typ
    variants/              role-tailored CVs: frontend, fullstack, data engineer,
                           data analyst
    companies/             one directory per application (gitignored, see below)
    details.md             raw dump of experience, not a CV itself
    faq.md                 answers to recurring application questions
    flake.nix              pins typst and the fonts, builds the PDFs
```

The template takes a [JSON Resume](https://jsonresume.org/schema) document, so every CV file follows that schema, written as YAML. A letter file is flat:

    name, email, phone, role, company, hiringManager, date, body

Missing fields drop out of the layout, except `date`, which falls back to today.

Free-text fields are Typst markup, not Markdown: write `*bold*`, `_italic_`, `#link("https://…")[text]`. On the CV side, `cv.typ` evaluates that markup for summaries, descriptions and highlights only; names, dates and URLs pass through verbatim. In a letter, the whole `body` is evaluated.

## Building

`nix build` produces a `result/` symlink with:

    result/resume.pdf                      inputs/info.yaml
    result/variants/resume-<role>.pdf      one per file in variants/

Company-specific applications live in `companies/`, which is gitignored and so absent from this repository. Each subdirectory holds an `info.yaml` (a CV), a `letter.yaml` (a cover letter), or both, and gets its PDFs built from whichever is present:

    nix build --impure .#companies-tailored-cvs

    result/companies/<name>/michele-decillis_cv.pdf
    result/companies/<name>/michele-decillis_cover-letter.pdf

The `--impure` flag is required. A flake's source is a git-filtered copy in the store, where `companies/` does not exist; the derivation therefore reads the real working directory through `$PWD`, so run it from the repository root. That also means `nix flake check` and `nix flake show`, which evaluate in pure mode, fail on this flake.

`nix build .#all` builds both packages under a single `result/`.

## Working on the content

`nix develop` (or direnv, via the checked-in `.envrc`) gives a shell with typst, the fonts, and two preview scripts:

    watch [file.yaml]           defaults to inputs/info.yaml
    watch-letter [file.yaml]    defaults to inputs/letter.yaml

Each one runs `typst watch` and opens the result in zathura, which reloads on every save. The PDF is a temporary file, named after the script so a CV and a letter can be watched side by side; closing zathura stops the compiler and removes it. zathura is not provided by the flake and has to be on `PATH`.

For a one-off compile:

    typst compile cv.typ out.pdf
    typst compile cv.typ out.pdf --input fileName=variants/data-analyst.yaml
    typst compile cover-letter.typ out.pdf --input fileName=inputs/letter.yaml

`fileName` picks the input file. Paths are resolved relative to the entry point, so run these from the repository root.

## Editing the CV

Edit `inputs/info.yaml` by hand, or add experience to `details.md` and run the `cv-details-parser` agent (Claude Code), which rewrites the CV and keeps the role variants in sync. The agent only rephrases what is already written in `details.md`; it never invents facts.
