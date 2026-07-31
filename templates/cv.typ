// Jake's Resume, ported to Typst.
//
// Original LaTeX template: Jake Gutierrez (MIT), based on
// https://github.com/sb2nov/resume.
//
// `jake(cv)` renders a JSON-Resume dictionary, the same shape altacv's
// `alta(cv)` takes, so the YAML files stay as they are. The building blocks
// above it map one to one onto the LaTeX macros of the original.

// The article-class 11pt sizes of the original.
#let sizes = (
  huge: 24pt, // \Huge — the name
  large: 12pt, // \large — section headings
  normal: 11pt, // \normalsize — entry titles
  small: 10pt, // \small — everything else
)

// \scshape. Lato and most sans faces ship no `smcp` table, and Typst does
// not synthesize small caps, so lowercase runs are uppercased at 0.78em
// instead. The regex splits the string into runs of one case, which keeps
// kerning inside each run.
#let caps(value) = {
  if type(value) != str { return smallcaps(value) }
  set text(tracking: 0.03em)
  for run in value.matches(regex("\p{Ll}+|[^\p{Ll}]+")) {
    let part = run.text
    if lower(part) == part and upper(part) != part {
      text(size: 0.78em, upper(part))
    } else { part }
  }
}

// --- building blocks -------------------------------------------------------

// \section. The accent colours the title and the rule; the original is black.
#let section-heading(title, accent: black) = block(
  above: 10pt,
  below: 8pt,
  breakable: false,
  width: 100%,
)[
  #set align(left)
  #text(size: sizes.large, weight: "bold", fill: accent, caps(title))
  #v(-4pt)
  #line(length: 100%, stroke: 0.6pt + accent)
]

// \resumeSubheading. Two rows in one grid, so the right column aligns.
// 97% is the 0.97\textwidth of the original.
#let entry-header(title, meta, subtitle, submeta) = block(
  above: 6pt,
  below: 0pt,
  breakable: false,
  width: 97%,
)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    row-gutter: 4pt,
    text(size: sizes.normal, weight: "bold", title),
    text(size: sizes.small, style: "italic", meta),
    text(size: sizes.normal, style: "italic", subtitle),
    align(right, text(size: sizes.small, style: "italic", submeta)),
  )
]

// \resumeProjectHeading. One row; the caller formats the left side.
#let entry-row(body, meta) = block(
  above: 6pt,
  below: 0pt,
  breakable: false,
  width: 97%,
)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    text(size: sizes.small, body),
    text(size: sizes.small, meta),
  )
]

// \resumeItemListStart/End.
#let bullets(items) = if items.len() > 0 {
  block(above: 6pt, below: 8pt, width: 100%)[
    #set text(size: sizes.small)
    #set par(leading: 0.5em)
    #list(indent: 0.1in, body-indent: 0.4em, spacing: 4pt, ..items)
  ]
}

// Not a Jake macro. JSON-Resume `summary` and `description` prose has no
// place in an all-bullets template, so it becomes a plain paragraph.
#let prose(body) = if body != none and body != "" {
  block(above: 4pt, below: 0pt, width: 97%)[
    #set text(size: sizes.small)
    #set par(leading: 0.5em, justify: true)
    #body
  ]
}

// --- JSON-Resume helpers ---------------------------------------------------

// Missing keys and explicit nulls both read as the default.
#let field(dict, key, default: "") = {
  let value = dict.at(key, default: default)
  if value == none { default } else { value }
}

// `join` on an empty array returns none, hence the guard.
#let joined(values, separator: ", ") = {
  let kept = values.filter(value => value != none and value != "")
  if kept == () { "" } else { kept.join(separator) }
}

#let months = (
  "Jan.",
  "Feb.",
  "Mar.",
  "Apr.",
  "May",
  "June",
  "July",
  "Aug.",
  "Sep.",
  "Oct.",
  "Nov.",
  "Dec.",
)

// "2025-09" becomes "Sep. 2025". Other formats, such as "2024/25", pass
// through unchanged.
#let format-date(value) = {
  let raw = str(value).trim()
  let matched = raw.match(regex("^(\d{4})-(\d{1,2})(?:-\d{1,2})?$"))
  if matched == none { return raw }
  let (year, month) = matched.captures.slice(0, 2)
  if int(month) < 1 or int(month) > 12 { return raw }
  months.at(int(month) - 1) + " " + year
}

// An entry that started but has no end date is ongoing.
#let date-range(entry) = {
  let start = format-date(field(entry, "startDate"))
  let end = format-date(field(entry, "endDate"))
  if start == "" { return end }
  if end == "" { return start + " – Present" }
  if start == end { start } else { start + " – " + end }
}

#let linked(label, url) = if url == "" { label } else { link(url, label) }

#let display-url(url) = url.replace(regex("^https?://(www\.)?"), "").trim(
  "/",
  at: end,
)

// "*Title* | _meta_", the one-line header shared by several sections.
#let titled-row(title, meta, date) = entry-row(
  if meta == "" { strong(title) } else {
    [#strong(title) #h(0.4em) | #h(0.4em) #emph(meta)]
  },
  date,
)

// --- sections --------------------------------------------------------------

// Each renderer takes the JSON-Resume array for its key. `jake` wraps the
// result in the section heading and the 0.15in indent.

#let work(entries) = {
  for entry in entries {
    entry-header(
      field(entry, "position"),
      date-range(entry),
      linked(field(entry, "name"), field(entry, "url")),
      field(entry, "location"),
    )
    prose(field(entry, "summary", default: none))
    bullets(field(entry, "highlights", default: ()))
  }
}

#let volunteer(entries) = {
  for entry in entries {
    entry-header(
      field(entry, "position"),
      date-range(entry),
      linked(field(entry, "organization"), field(entry, "url")),
      field(entry, "location"),
    )
    prose(field(entry, "summary", default: none))
    bullets(field(entry, "highlights", default: ()))
  }
}

#let education(entries) = {
  for entry in entries {
    entry-header(
      linked(field(entry, "institution"), field(entry, "url")),
      date-range(entry),
      joined((field(entry, "studyType"), field(entry, "area"))),
      field(entry, "location"),
    )
    prose(field(entry, "summary", default: none))

    // `courses` has no slot in the original template.
    let courses = field(entry, "courses", default: ())
    let coursework = if courses == () { () } else {
      ([*Relevant coursework:* #joined(courses)],)
    }
    bullets(field(entry, "highlights", default: ()) + coursework)
  }
}

#let projects(entries) = {
  for entry in entries {
    titled-row(
      linked(field(entry, "name"), field(entry, "url")),
      joined(field(entry, "keywords", default: ())),
      date-range(entry),
    )
    prose(field(entry, "description", default: none))
    bullets(field(entry, "highlights", default: ()))
  }
}

#let awards(entries) = {
  for entry in entries {
    titled-row(
      linked(field(entry, "title"), field(entry, "url")),
      field(entry, "awarder"),
      format-date(field(entry, "date")),
    )
    prose(field(entry, "summary", default: none))
  }
}

#let certificates(entries) = {
  for entry in entries {
    titled-row(
      linked(field(entry, "name"), field(entry, "url")),
      field(entry, "issuer"),
      format-date(field(entry, "date")),
    )
  }
}

#let publications(entries) = {
  for entry in entries {
    titled-row(
      linked(field(entry, "name"), field(entry, "url")),
      field(entry, "publisher"),
      format-date(field(entry, "releaseDate")),
    )
    prose(field(entry, "summary", default: none))
  }
}

#let references(entries) = {
  for entry in entries {
    titled-row(field(entry, "name"), "", "")
    let body = field(entry, "reference", default: none)
    if body != none { prose(emph(body)) }
  }
}

// One bold-labelled line per group, no bullets.
#let skills(groups) = block(above: 4pt, width: 100%)[
  #set text(size: sizes.small)
  #set par(leading: 0.5em)
  #for group in groups {
    let label = field(group, "name")
    let body = joined(field(group, "keywords", default: ()))
    if body == "" { body = field(group, "level") }
    if label == "" [#body \ ] else [*#label*: #body \ ]
  }
]

#let one-liner(entries) = block(above: 4pt, width: 100%)[
  #set text(size: sizes.small)
  #joined(entries)
]

#let languages(entries) = one-liner(entries.map(entry => {
  let fluency = field(entry, "fluency")
  let name = field(entry, "language")
  if fluency == "" { name } else { name + " (" + fluency + ")" }
}))

#let interests(entries) = one-liner(entries.map(entry => {
  let keywords = joined(field(entry, "keywords", default: ()))
  let name = field(entry, "name")
  if keywords == "" { name } else { name + " (" + keywords + ")" }
}))

// JSON-Resume key -> (default heading, renderer).
#let renderers = (
  work: ("Experience", work),
  education: ("Education", education),
  projects: ("Projects", projects),
  skills: ("Technical Skills", skills),
  awards: ("Awards", awards),
  certificates: ("Certifications", certificates),
  languages: ("Languages", languages),
  publications: ("Publications", publications),
  volunteer: ("Volunteering", volunteer),
  interests: ("Interests", interests),
  references: ("References", references),
)

// --- header ----------------------------------------------------------------

// Name, then the pipe-separated contact line. These links are underlined,
// as in the original; the ones in the body are not.
#let header(basics, accent: none) = {
  let location = field(basics, "location", default: (:))
  let phone = field(basics, "phone")
  let email = field(basics, "email")
  let url = field(basics, "url")
  let profiles = field(basics, "profiles", default: ()).map(p => field(p, "url"))

  let links = profiles.filter(u => u != "").map(u => link(u, display-url(u)))

  let contacts = (
    joined((
      field(location, "city"),
      field(location, "region"),
      field(location, "countryCode"),
    )),
    if phone != "" { link("tel:" + phone.replace(" ", ""), phone) },
    if email != "" { link("mailto:" + email, email) },
    if url != "" { link(url, display-url(url)) },
    ..links,
  ).filter(c => c != none and c != "")

  set align(center)

  block(below: 8pt, text(
    size: sizes.huge,
    fill: accent,
    weight: "bold",
    caps(field(basics, "name")),
  ))

  let label = field(basics, "label")
  if label != "" { block(below: 4pt, text(size: sizes.large, label)) }

  block(below: 12pt)[
    #show link: underline
    #text(size: sizes.small, contacts.join([ #h(0.3em) | #h(0.3em) ]))
  ]

  set align(left)
  prose(field(basics, "summary", default: none))
}

// --- entry point -----------------------------------------------------------

// Navy stays legible once printed in greyscale.
#let navy = rgb("#1c3f6e")

// One family per entry that exists: Typst warns once per unresolved name,
// so a longer fallback list means font warnings on every compile. `flake.nix`
// pins Lato, so both `nix build` and `nix develop` resolve it.
#let sans = ("Lato")

// `cv` is a JSON-Resume dictionary. `sections` picks the keys to render and
// their order; `labels` overrides single headings, for example
// `labels: (awards: "Accomplishments")`. For the original LaTeX look, pass
// `font: ("New Computer Modern",)` and `accent: black`.
#let jake(
  cv,
  sections: (
    "education",
    "work",
    "projects",
    "skills",
    "awards",
    "certificates",
    "languages",
  ),
  labels: (:),
  accent: navy,
  font: sans,
  font-size: sizes.normal,
  margin: (x: 0.5in, y: 0.5in),
) = {
  let basics = field(cv, "basics", default: (:))
  let name = field(basics, "name")

  set document(
    author: name,
    title: if name == "" { "Resume" } else { name + " - Resume" },
  )
  set page(paper: "a4", margin: margin)
  set text(font: font, size: font-size, lang: "en", hyphenate: false)
  set par(leading: 0.55em, spacing: 0.65em)
  set list(marker: text(size: 0.9em, sym.bullet))
  show link: set text(fill: black)

  header(basics, accent: accent)

  for key in sections {
    assert(key in renderers, message: "template.typ: unknown section '" + key + "'")
    let entries = field(cv, key, default: ())
    if entries == () { continue }

    let (default-label, render) = renderers.at(key)
    section-heading(labels.at(key, default: default-label), accent: accent)
    pad(left: 0.15in, render(entries))
  }
}
