// Cover letter in the look of the CV in `cv.typ`. The content is a flat YAML file:
//     name:  ...
//     email: ...
//     phone: ...
//     role:  ...
//     company: ...
//     hiringManager: ...
//     date: ...
//     body: |
//       Dear hiring team, ...
//
// `body` is Typst markup, so `*bold*`, `_italic_`, `#link(..)[..]` and lists render. Missing fields drop out of the layout, except `date`, which falls back to today. `date` prints verbatim, so write it as it must appear: `2026-07-31` stays in that form. `body` keeps its own salutation; `hiringManager` and `company` form the address block above it.
// Typst reads the clock through SOURCE_DATE_EPOCH, which Nix pins to 1980 for reproducible builds. `flake.nix` resets it, so the fallback date is only today for callers that do the same.
// Reading the YAML is the caller's job. Typst resolves a relative path against the file the `yaml()` call is written in, so a loader here would look every letter up inside `templates/`. Render through `cover-letter.typ` at the repo root instead.

#import "cv.typ": caps, field, joined, navy, sans, section-heading, sizes

#let cover-letter(letter, accent: navy) = {
  let name = field(letter, "name")
  let role = field(letter, "role")
  let phone = field(letter, "phone")
  let email = field(letter, "email")

  set document(
    author: name,
    title: joined((name, role, "Cover Letter"), separator: " - "),
  )
  // Wider than the CV's 0.5in, which sets short bullets rather than prose.
  set page(paper: "a4", margin: (x: 1in, y: 0.75in))
  set text(font: sans, size: sizes.normal, lang: "en", hyphenate: false)
  set par(leading: 0.6em, spacing: 0.9em, justify: true)
  show link: set text(fill: black)

  set align(center)

  block(below: 8pt, text(
    size: sizes.huge,
    fill: accent,
    weight: "bold",
    caps(name),
  ))

  block(below: 12pt)[
    #show link: underline
    #text(size: sizes.small, joined(
      (
        if phone != "" { link("tel:" + phone.replace(" ", ""), phone) },
        if email != "" { link("mailto:" + email, email) },
      ),
      separator: [ #h(0.3em) | #h(0.3em) ],
    ))
  ]

  set align(left)

  if role != "" {
    section-heading("Application for the " + role + " role", accent: accent)
  }

  block(above: 10pt, below: 14pt, width: 100%, text(size: sizes.small, grid(
    columns: (1fr, auto),
    align: (left, right),
    joined(
      (field(letter, "hiringManager"), field(letter, "company")),
      separator: linebreak(),
    ),
    field(
      letter,
      "date",
      default: datetime.today().display("[day padding:none] [month repr:long] [year]"),
    ),
  )))

  show link: underline
  eval(field(letter, "body"), mode: "markup")
}
