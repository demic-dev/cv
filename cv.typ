#import "templates/cv.typ": jake

// --- YAML injection -------------------------------------------------------
//
// The template places string fields verbatim, so Typst markup written in the
// data (e.g. `*bold*`, `_italic_`, `#link(...)`) would show up literally.
// Reading from YAML and running the free-text fields through `eval(...,
// mode: "markup")` instead makes that markup render, while every other field
// (names, dates, urls) passes straight through to `jake`, which accepts raw
// JSON-Resume shapes.
//
// The paths below are the free-text fields. Each is a chain of keys leading
// to a string (or an array of strings, for `highlights`); arrays met along
// the way are mapped over.
#let _content-paths = (
  ("basics", "summary"),
  ("work", "summary"),
  ("work", "highlights"),
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
// live outside this path and keep the template's own styling.
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

#let jake-from-yaml(source, ..rest) = {
  let cv = _content-paths.fold(yaml(source), (data, path) => _eval-at(
    data,
    path,
  ))
  jake(cv, ..rest)
}

// --------------------------------------------------------------------------

#let fileName = if "fileName" in sys.inputs {
  sys.inputs.at("fileName")
} else {
  "inputs/info.yaml"
}

#jake-from-yaml(
  fileName,
  labels: (awards: "Accomplishments"),
  sections: (
    "work",
    "education",
    "projects",
    "skills",
    "awards",
    "languages",
    "certificates",
  ),
)
