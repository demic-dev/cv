{
  description = ''
  My personal CV's flake, which generates, from its source, visually polished CV OR tailored for certain job listings.
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      # companies/ is .gitignore'd, so it never reaches the flake's source: that source is a git-filtered copy in the store, and `./companies` resolves inside *that* copy, where the directory does not exist — `--impure` does not change this. The only way in is the real working directory, which `--impure` does expose, through $PWD:
      #
      #     nix build --impure .#companies-tailored-cvs
      #
      # Run it from the repo root, since $PWD is what gets read. Being impure, this attribute is also why `nix flake check` and `nix flake show` fail on the flake — they evaluate it in pure mode.
      companiesSrc =
        let pwd = builtins.getEnv "PWD";
        in
        if pwd == "" then
          throw "companies-tailored-cvs reads the .gitignore'd companies/, so it needs: nix build --impure .#companies-tailored-cvs (from the repo root)"
        else
          builtins.path {
            path = /. + pwd + "/companies";
            name = "companies-src";
          };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "cv";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [ pkgs.typst ];
            TYPST_FONT_PATHS = "${pkgs.lato}/share/fonts";

            buildPhase = ''
              runHook preBuild

              export HOME="$TMPDIR"
              mkdir -p "$HOME/.cache/typst"

              typst compile cv.typ resume.pdf

              mkdir -p variants
              for variant in variants/*.yaml; do
                [ -s "$variant" ] || continue
                name="$(basename "$variant" .yaml)"
                typst compile cv.typ "variants/resume-$name.pdf" --input fileName="$variant"
              done

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out/variants
              cp resume.pdf $out/
              cp variants/resume-*.pdf $out/variants/

              runHook postInstall
            '';
          };

          companies-tailored-cvs = pkgs.stdenvNoCC.mkDerivation {
            pname = "companies-tailored-cvs";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [ pkgs.typst ];
            TYPST_FONT_PATHS = "${pkgs.lato}/share/fonts";

            buildPhase = ''
              runHook preBuild

              export HOME="$TMPDIR"
              mkdir -p "$HOME/.cache/typst"

              cp -r ${companiesSrc} companies
              chmod -R u+w companies

              for dir in companies/*/; do
                dir="''${dir%/}"
                [ -f "$dir/info.yaml" ] || continue
                typst compile cv.typ "$dir/cv.pdf" --input fileName="$dir/info.yaml"
              done

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/companies

              for pdf in companies/*/cv.pdf; do
                [ -e "$pdf" ] || continue
                name="$(basename "$(dirname "$pdf")")"
                mkdir -p "$out/companies/$name"
                cp "$pdf" "$out/companies/$name/michele-decillis_cv.pdf"
              done
              runHook postInstall
            '';
          };

          # Both of the above under one result/: resume.pdf and variants/ from `default`, companies/ from `companies-tailored-cvs`.
          all = pkgs.symlinkJoin {
            name = "cv-all";
            paths = [ default companies-tailored-cvs ];
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # `watch [file.yaml]` — recompile on save and preview in zathura.
          # A script rather than a shellHook function, because .envrc loads
          # this shell through direnv: a shellHook runs in bash and its
          # functions never reach an interactive fish.
          watch = pkgs.writeShellScriptBin "watch" ''
            set -euo pipefail

            file="''${1:-generic.yaml}"
            pdf=temp.pdf

            if [ ! -f cv.typ ]; then
              echo "watch: no cv.typ here, run this from the repo root" >&2
              exit 1
            fi
            if [ ! -f "$file" ]; then
              echo "watch: no such file: $file" >&2
              exit 1
            fi
            if ! command -v zathura >/dev/null; then
              echo "watch: zathura is not on PATH" >&2
              exit 1
            fi

            typst watch cv.typ "$pdf" --input fileName="$file" &
            typst=$!
            trap 'kill $typst 2>/dev/null || true; rm -f "$pdf"' EXIT INT TERM

            # zathura exits if the file is not there yet, so wait for the
            # first compile. It reloads on its own afterwards.
            while [ ! -s "$pdf" ]; do
              if ! kill -0 $typst 2>/dev/null; then
                echo "watch: typst exited before writing $pdf" >&2
                exit 1
              fi
              sleep 0.1
            done

            # Foreground on purpose: closing zathura has to end the script so
            # the trap can stop typst and delete the PDF. `& disown` would put
            # it out of reach.
            zathura "$pdf"
          '';
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.typst watch ];
            TYPST_FONT_PATHS = "${pkgs.font-awesome}/share/fonts:${pkgs.lato}/share/fonts";
          };
        });
    };
}
