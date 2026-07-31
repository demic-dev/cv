#import "templates/cover-letter.typ": cover-letter

// Which letter to render, as for `cv.typ`:
//
//     typst compile cover-letter.typ out.pdf --input fileName=inputs/letter.yaml
//
// Paths are relative to this file, so run it from the repo root.
#let fileName = if "fileName" in sys.inputs {
  sys.inputs.at("fileName")
} else {
  panic("cover-letter.typ: no letter given, pass --input fileName=<file>.yaml")
}

#cover-letter(yaml(fileName))
