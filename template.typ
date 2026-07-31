// ---------------------------------------------------------------------------
// Jake's Resume, ported to Typst.
//
// Original LaTeX template: Jake Gutierrez (MIT), itself based on
// https://github.com/sb2nov/resume. Single column, small-caps section
// headings with a rule underneath, two-line entry headers, tight bullets —
// deliberately plain so ATS parsers get everything.
//
// The file has two halves:
//   1. the building blocks, one per LaTeX macro (\resumeSubheading & co.);
//   2. `jake(cv)`, which renders a JSON-Resume dictionary with them, the
//      same shape altacv's `alta(cv)` takes, so the YAML files stay as-is.
// ---------------------------------------------------------------------------

// Type sizes are the article-class 11pt ones the original relies on, so the
// proportions carry over unchanged.
#let sizes = (
  huge: 24pt, // \Huge  — the name
  large: 12pt, // \large — section headings
  normal: 11pt, // \normalsize — entry titles
  small: 10pt, // \small — everything else
)

// Sans faces (Lato included) ship no `smcp` table and Typst does not
// synthesize small caps, so `smallcaps()` would quietly render the name and
// the section headings as plain text — the one place the original leans on
// \scshape. Do it by hand instead: lowercase runs become uppercase at
// `ratio` of the surrounding size, everything else is left alone. Content
// (rather than a plain string) can't be inspected, so it falls back to the
// real feature, which is what serif faces want anyway.
#let caps(value, ratio: 0.78, tracking: 0.03em) = {
  if type(value) != str { return smallcaps(value) }

  // Group adjacent clusters of the same case, so a word costs one `text`
  // call rather than one per letter.
  let runs = ()
  for cluster in value.clusters() {
    let small = lower(cluster) == cluster and upper(cluster) != cluster
    if runs.len() > 0 and runs.last().at(0) == small {
      runs.at(runs.len() - 1) = (small, runs.last().at(1) + cluster)
    } else {
      runs.push((small, cluster))
    }
  }

  set text(tracking: tracking)
  for (small, run) in runs {
    if small { text(size: ratio * 1em, upper(run)) } else { run }
  }
}

// --- building blocks -------------------------------------------------------

// \section — small caps, ragged right, hairline rule underneath. The accent
// colours both, the one deviation from the original's all-black rule.
#let resume-section(title, accent: black) = block(
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

// \resumeSubHeadingListStart/End — the outer itemize has an empty label, so
// all it contributes is the 0.15in indent.
#let resume-entries(body) = pad(left: 0.15in, body)

// \resumeSubheading — bold title with meta flush right, then a smaller
// italic line with its own flush-right meta. Both rows are one grid so the
// right column lines up between them.
#let resume-subheading(title, meta, subtitle, submeta) = block(
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

// \resumeProjectHeading — a single line, left content already formatted by
// the caller (project name, separator, tech stack), meta flush right.
#let resume-heading(body, meta) = block(
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

// \resumeItemListStart/End — the bullets hanging under an entry.
#let resume-items(items) = {
  let items = items.filter(i => i != none)
  if items.len() == 0 { return }
  block(above: 6pt, below: 8pt, width: 100%)[
    #set text(size: sizes.small)
    #set par(leading: 0.5em)
    #list(
      indent: 0.1in,
      body-indent: 0.4em,
      spacing: 4pt,
      ..items,
    )
  ]
}

// Not a Jake macro: the JSON-Resume `summary`/`description` prose has no
// place in an all-bullets template, so it gets a plain small paragraph
// between the entry header and its bullets.
#let resume-prose(body) = block(above: 4pt, below: 0pt, width: 97%)[
  #set text(size: sizes.small)
  #set par(leading: 0.5em, justify: true)
  #body
]

// --- JSON-Resume helpers ---------------------------------------------------

#let _str(value) = if value == none { "" } else if type(value) == str {
  value
} else { str(value) }

#let _blank(value) = _str(value).trim() == ""

// `at` that tolerates both a missing key and an explicit null.
#let _get(dict, key, default: none) = {
  if type(dict) != dictionary { return default }
  let value = dict.at(key, default: default)
  if value == none { default } else { value }
}

#let _months = (
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

// "2025-09" -> "Sep. 2025". Anything that isn't a YYYY-MM[-DD] date passes
// through verbatim, which keeps hand-written values like "2024/25" intact.
#let _date(value) = {
  let raw = _str(value).trim()
  if raw == "" { return "" }
  let matched = raw.match(regex("^(\d{4})-(\d{1,2})(?:-\d{1,2})?$"))
  if matched == none { return raw }
  let (year, month) = matched.captures.slice(0, 2)
  let index = int(month)
  if index < 1 or index > 12 { return raw }
  _months.at(index - 1) + " " + year
}

// A missing end date means the entry is ongoing — but only if it ever
// started, so undated entries stay blank rather than claiming "Present".
#let _date-range(entry, present: "Present") = {
  let start = _date(_get(entry, "startDate"))
  let end = _date(_get(entry, "endDate"))
  if start == "" and end == "" { return "" }
  if start == "" { return end }
  if end == "" { return start + " – " + present }
  if start == end { return start }
  start + " – " + end
}

// Links are unstyled here (LaTeX's `hidelinks`); the header underlines its
// own. `url` may be missing, in which case the label is plain text.
#let _linked(label, url) = if _blank(url) { label } else {
  link(_str(url), label)
}

#let _display-url(url) = {
  let bare = _str(url).replace(regex("^https?://(www\.)?"), "")
  bare.trim("/", at: end)
}

// Drops empties before joining, so absent fields leave no stray separators.
// Always a string: `join` on an empty array would hand back `none`.
#let _joined(values, separator: ", ") = {
  let present = values.map(_str).filter(value => value.trim() != "")
  if present.len() == 0 { "" } else { present.join(separator) }
}

// --- sections --------------------------------------------------------------

// Each renderer takes the raw JSON-Resume array for its key and returns the
// section body; `jake` wraps it in the heading and the 0.15in indent.

#let _prose-of(entry, key) = {
  let value = _get(entry, key)
  if value == none or (type(value) == str and value.trim() == "") {
    none
  } else { value }
}

#let _highlights-of(entry, key: "highlights") = {
  let value = _get(entry, key, default: ())
  if type(value) == array { value } else { (value,) }
}

#let _entry(head, prose, highlights) = {
  head
  if prose != none { resume-prose(prose) }
  resume-items(highlights)
}

// Experience: position + dates, then employer + location.
#let _work(entries) = {
  for entry in entries {
    let head = resume-subheading(
      _str(_get(entry, "position")),
      _date-range(entry),
      _linked(_str(_get(entry, "name")), _get(entry, "url")),
      _str(_get(entry, "location")),
    )
    _entry(head, _prose-of(entry, "summary"), _highlights-of(entry))
  }
}

// Education: institution + location, then degree + dates. `courses` has no
// slot in the original, so it becomes the coursework bullet people usually
// add to this template by hand.
#let _education(entries) = {
  for entry in entries {
    let degree = _joined((_get(entry, "studyType"), _get(entry, "area")))
    let head = resume-subheading(
      _linked(_str(_get(entry, "institution")), _get(entry, "url")),
      _date-range(entry),
      degree,
      _str(_get(entry, "location")),
    )
    let courses = _get(entry, "courses", default: ())
    let coursework = if courses.len() > 0 {
      ([*Relevant coursework:* #_joined(courses)],)
    } else { () }
    _entry(
      head,
      _prose-of(entry, "summary"),
      _highlights-of(entry) + coursework,
    )
  }
}

// Projects: name | tech stack, dates flush right.
#let _projects(entries) = {
  for entry in entries {
    let name = text(
      weight: "bold",
      _linked(_str(_get(entry, "name")), _get(entry, "url")),
    )
    let stack = _joined(_get(entry, "keywords", default: ()))
    let head = resume-heading(
      if stack == "" { name } else {
        [#name #h(0.4em) | #h(0.4em) #emph(stack)]
      },
      _date-range(entry),
    )
    _entry(head, _prose-of(entry, "description"), _highlights-of(entry))
  }
}

// Technical Skills: one bold-labelled line per group, no bullets.
#let _skills(groups) = block(above: 4pt, width: 100%)[
  #set text(size: sizes.small)
  #set par(leading: 0.5em)
  #for group in groups {
    let keywords = _joined(_get(group, "keywords", default: ()))
    let label = _str(_get(group, "name"))
    let body = if keywords != "" { keywords } else { _str(_get(group, "level")) }
    if label == "" [#body \ ] else [*#label*: #body \ ]
  }
]

#let _languages(entries) = block(above: 4pt, width: 100%)[
  #set text(size: sizes.small)
  #_joined(entries.map(entry => {
    let name = _str(_get(entry, "language"))
    let fluency = _str(_get(entry, "fluency"))
    if fluency == "" { name } else { name + " (" + fluency + ")" }
  }))
]

// Awards / certificates / publications share a shape: a titled one-liner
// with a date on the right, optionally followed by prose.
#let _titled(entries, title-key, meta-keys, date-key: "date", prose-key: none) = {
  for entry in entries {
    let meta = _joined(meta-keys.map(key => _get(entry, key)))
    let title = text(
      weight: "bold",
      _linked(_str(_get(entry, title-key)), _get(entry, "url")),
    )
    resume-heading(
      if meta == "" { title } else {
        [#title #h(0.4em) | #h(0.4em) #emph(meta)]
      },
      _date(_get(entry, date-key)),
    )
    let prose = if prose-key == none { none } else {
      _prose-of(entry, prose-key)
    }
    if prose != none { resume-prose(prose) }
    resume-items(_highlights-of(entry))
  }
}

#let _awards(entries) = _titled(
  entries,
  "title",
  ("awarder",),
  prose-key: "summary",
)

#let _certificates(entries) = _titled(entries, "name", ("issuer",))

#let _publications(entries) = _titled(
  entries,
  "name",
  ("publisher",),
  date-key: "releaseDate",
  prose-key: "summary",
)

// Volunteering mirrors Experience.
#let _volunteer(entries) = {
  for entry in entries {
    let head = resume-subheading(
      _str(_get(entry, "position")),
      _date-range(entry),
      _linked(_str(_get(entry, "organization")), _get(entry, "url")),
      _str(_get(entry, "location")),
    )
    _entry(head, _prose-of(entry, "summary"), _highlights-of(entry))
  }
}

#let _interests(entries) = block(above: 4pt, width: 100%)[
  #set text(size: sizes.small)
  #_joined(entries.map(entry => {
    let name = _str(_get(entry, "name"))
    let keywords = _joined(_get(entry, "keywords", default: ()))
    if keywords == "" { name } else { name + " (" + keywords + ")" }
  }))
]

#let _references(entries) = {
  for entry in entries {
    resume-heading(text(weight: "bold", _str(_get(entry, "name"))), "")
    let reference = _prose-of(entry, "reference")
    if reference != none { resume-prose(emph(reference)) }
  }
}

// JSON-Resume key -> (default heading, renderer).
#let renderers = (
  work: ("Experience", _work),
  education: ("Education", _education),
  projects: ("Projects", _projects),
  skills: ("Technical Skills", _skills),
  awards: ("Awards", _awards),
  certificates: ("Certifications", _certificates),
  languages: ("Languages", _languages),
  publications: ("Publications", _publications),
  volunteer: ("Volunteering", _volunteer),
  interests: ("Interests", _interests),
  references: ("References", _references),
)

// --- header ----------------------------------------------------------------

// Name, then the pipe-separated contact line. Unlike the rest of the
// document these links are underlined, as in the original.
#let _header(basics, accent: none, show-label: true) = {
  let contacts = ()

  let location = _get(basics, "location", default: (:))
  let place = _joined((
    _get(location, "city"),
    _get(location, "region"),
    _get(location, "countryCode"),
  ))
  if place != "" { contacts.push(place) }

  let phone = _str(_get(basics, "phone"))
  if phone != "" { contacts.push(link("tel:" + phone.replace(" ", ""), phone)) }

  let email = _str(_get(basics, "email"))
  if email != "" { contacts.push(link("mailto:" + email, email)) }

  let url = _str(_get(basics, "url"))
  if url != "" { contacts.push(link(url, _display-url(url))) }

  for profile in _get(basics, "profiles", default: ()) {
    let target = _str(_get(profile, "url"))
    if target == "" { continue }
    contacts.push(link(target, _display-url(target)))
  }

  set align(center)

  block(below: 8pt, text(
    size: sizes.huge,
    fill: accent,
    weight: "bold",
    caps(_str(_get(basics, "name"))),
  ))

  let label = _str(_get(basics, "label"))
  if show-label and label != "" {
    block(below: 4pt, text(size: sizes.large, label))
  }

  block(below: 12pt)[
    #show link: underline
    #text(size: sizes.small, contacts.join([ #h(0.3em) | #h(0.3em) ]))
  ]

  let summary = _prose-of(basics, "summary")
  if summary != none {
    set align(left)
    resume-prose(summary)
  }
}

// --- entry point -----------------------------------------------------------

// Section headings and their rules. Navy reads as near-black once printed
// in greyscale, so it stays legible on a recruiter's laser printer.
#let navy = rgb("#1c3f6e")

// The original offers a commented-out block of sans options (Fira Sans,
// Roboto, Noto Sans, Source Sans); Lato is the pick here because
// `flake.nix` already pins it, so both `nix build` and `nix develop`
// resolve it without depending on the host's font set. Kept a single
// family on purpose: Typst warns once per unresolved name, so listing
// fallbacks would put font warnings on every compile.
#let sans = ("New Computer Modern", "Lato",)

// `cv` is a JSON-Resume dictionary — the same shape altacv's `alta` takes.
// `sections` picks which keys are rendered and in what order; `labels`
// overrides individual headings, e.g. `labels: (awards: "Accomplishments")`.
// Pass `font: ("New Computer Modern",), accent: black` for the original
// LaTeX look.
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
  show-label: true,
  font: sans,
  font-size: sizes.normal,
  margin: (x: 0.5in, y: 0.5in),
) = {
  let basics = _get(cv, "basics", default: (:))
  let name = _str(_get(basics, "name"))

  set document(
    author: name,
    title: if name == "" { "Resume" } else { name + " - Resume" },
  )
  set page(paper: "a4", margin: margin)
  set text(font: font, size: font-size, lang: "en", hyphenate: false)
  set par(leading: 0.55em, spacing: 0.65em)
  set list(marker: text(size: 0.9em, sym.bullet))
  show link: set text(fill: black)

  _header(basics, accent: accent, show-label: show-label)

  for key in sections {
    if key not in renderers {
      panic("template.typ: unknown section '" + key + "'")
    }
    let entries = _get(cv, key, default: ())
    if type(entries) != array or entries.len() == 0 { continue }

    let (default-label, render) = renderers.at(key)
    resume-section(labels.at(key, default: default-label), accent: accent)
    resume-entries(render(entries))
  }
}
