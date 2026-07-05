#import "@preview/altacv:1.5.0": alta, palettes

// --- YAML injection -------------------------------------------------------
//
// `alta-from-json` places string fields verbatim, so Typst markup written
// in the data (e.g. `*bold*`, `_italic_`, `#link(...)`) shows up literally.
// Reading from YAML and running the free-text fields through `eval(...,
// mode: "markup")` instead makes that markup render, while every other
// field (names, dates, urls) passes straight through to `alta`, which
// already accepts raw JSON-Resume shapes.
//
// The paths below are the free-text fields — same set altacv treats as
// content. Each is a chain of keys leading to a string (or an array of
// strings, for `highlights`); arrays met along the way are mapped over.
#let _content-paths = (
  ("basics", "summary"),
  ("work", "summary"),
  ("work", "highlights"),
  ("focusAreas", "focusAreas"),
  ("projects", "description"),
  ("projects", "highlights"),
  ("volunteer", "summary"),
  ("volunteer", "highlights"),
  ("awards", "summary"),
  ("publications", "summary"),
  ("references", "reference"),
)

// Free-text fields render their markup here. Links inside these fields
// (bullets, descriptions, summaries) are underlined; header/section links
// live outside this path and keep altacv's own styling.
#let _eval-markup(value) = if type(value) == str {
  [#show link: underline
    #eval(value, mode: "markup")]
} else { value }

// Follow `path` into `value`, evaluating the markup string(s) at the leaf.
// Missing keys are left untouched, so partially-filled entries are fine.
#let _eval-at(value, path) = {
  if value == none { return value }
  if type(value) == array { return value.map(v => _eval-at(v, path)) }
  if path.len() == 0 { return _eval-markup(value) }
  let (key, ..rest) = path
  if type(value) == dictionary and key in value {
    value.insert(key, _eval-at(value.at(key), rest))
  }
  value
}

#let alta-from-yaml(source, ..rest) = {
  let cv = _content-paths.fold(yaml(source), (data, path) => _eval-at(
    data,
    path,
  ))
  alta(cv, ..rest)
}

// --------------------------------------------------------------------------

#let columnRatio = if "columnRatio" in sys.inputs {
  float(sys.inputs.at("columnRatio"))
} else {
  0.649
}

#let fileName = if "fileName" in sys.inputs {
  sys.inputs.at("fileName")
} else {
  "generic.yaml"
}

// The custom section layout is meaningful only for the single-column
// layout (columnRatio == 1, where altacv concatenates left + right in
// order). In two-column mode, fall back to altacv's default placement.
#let columnSections = if columnRatio == 1 {
  (
    leftColumnSections: (
      "work",
      "projects",
      "education",
      "skills",
      "awards",
      "certificates",
      "languages",
    ),
    rightColumnSections: (
      "focusAreas",
      "interests",
      "volunteer",
      "references",
      "publications",
    ),
  )
} else { (:) }

#alta-from-yaml(
  fileName,
  labels: (awards: "Accomplishments"),
  preferences: (
    columnRatio: columnRatio,
    accent: palettes.navy,
    ..columnSections,
  ),
)
