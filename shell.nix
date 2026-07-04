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

    if [[ ! -f "*_cv.pdf" ]] || [[ "cv.typ" -nt "*_cv.pdf" ]]; then
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

    echo "Done!"
    exit 0
  '';
}
