{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    typst
    font-awesome
    lato
  ];

  TYPST_FONT_PATHS = "${pkgs.font-awesome}/share/fonts:${pkgs.lato}/share/fonts";

  shellHook = ''
    for dir in job-hunt/*/; do
        # Skip if directory doesn't exist
        [[ ! -d "$dir" ]] && continue

        # Check if cv.typ exists in this directory
        if [[ -f "$dir/cv.typ" ]]; then

            # Compile if cv.pdf doesn't exist OR cv.typ is newer than cv.pdf
            if [[ ! -f "$dir/cv.pdf" ]] || [[ "$dir/cv.typ" -nt "$dir/cv.pdf" ]]; then
                echo "Compiling: $dir/cv.typ"
                typst compile "$dir/cv.typ" "$dir/cv.pdf"
                if [[ $? -eq 0 ]]; then
                    echo "✓ Generated: $dir/cv.pdf"
                else
                    echo "✗ Failed: $dir/cv.typ"
                fi
            else
                echo "⊘ Skipped: $dir (cv.pdf is up-to-date)"
            fi
            # Compile if cover-letter.pdf doesn't exist OR cover-letter.typ is newer than cover-letter.pdf
            if [[ ! -f "$dir/cover-letter.pdf" ]] || [[ "$dir/cover-letter.typ" -nt "$dir/cover-letter.pdf" ]]; then
                echo "Compiling: $dir/cover-letter.typ"
                typst compile "$dir/cover-letter.typ" "$dir/cover-letter.pdf" --root .
                if [[ $? -eq 0 ]]; then
                    echo "✓ Generated: $dir/cover-letter.pdf"
                else
                    echo "✗ Failed: $dir/cover-letter.typ"
                fi
            else
                echo "⊘ Skipped: $dir (cover-letter.pdf is up-to-date)"
            fi
        fi
    done

    if [[ ! -f "*_cv.pdf" ]] || [[ "resume.yaml" -nt "*_cv.pdf" ]]; then
        echo "Compiling main CV at cv.typ..."
        typst compile "cv.typ" "michele-de-cillis_cv.pdf"
        if [[ $? -eq 0 ]]; then
            echo "✓ Generated: $dir/cv.pdf"
        else
            echo "✗ Failed: $dir/cv.typ"
        fi
        typst compile "cv.typ" "cv-ATSREADY.pdf" --input columnRatio=1
        if [[ $? -eq 0 ]]; then
            echo "✓ Generated: $dir/cv-ATSREADY.pdf"
        else
            echo "✗ Failed: $dir/cv.typ"
        fi
    fi

    # Compile each role-tailored variant in variants/ into its own
    # {variant}_cv.pdf and ATS-ready {variant}_cv-ATSREADY.pdf, feeding the
    # variant's yaml path to cv.typ via the fileName input.
    for variant in variants/*.yaml; do
        # Skip if the glob didn't match anything
        [[ ! -f "$variant" ]] && continue

        # Skip variants the agent hasn't filled in yet (empty files)
        if [[ ! -s "$variant" ]]; then
            echo "⊘ Skipped: $variant (empty, not yet generated)"
            continue
        fi

        name="$(basename "$variant" .yaml)"

        # Recompile only if a PDF is missing or the variant yaml is newer
        if [[ ! -f "variants/''${name}_cv.pdf" ]] || [[ "$variant" -nt "variants/''${name}_cv.pdf" ]]; then
            echo "Compiling variant: $variant"
            typst compile "cv.typ" "variants/''${name}_cv.pdf" --input fileName="$variant"
            if [[ $? -eq 0 ]]; then
                echo "✓ Generated: variants/''${name}_cv.pdf"
            else
                echo "✗ Failed: $variant"
            fi

            typst compile "cv.typ" "variants/''${name}_cv-ATSREADY.pdf" --input fileName="$variant" --input columnRatio=1
            if [[ $? -eq 0 ]]; then
                echo "✓ Generated: variants/''${name}_cv-ATSREADY.pdf"
            else
                echo "✗ Failed: $variant (ATS)"
            fi
        else
            echo "⊘ Skipped: $variant (PDFs are up-to-date)"
        fi
    done

    echo "Done!"
    exit 0
  '';
}
