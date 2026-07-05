{
  description = ''
  My personal CV's flake, which generates, from its source, visually polished CV + its variants and its ATS-friendly version (1 column instead of 2).
  '';

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      # cv.typ's transitive @preview package dependencies, pinned so the
      # build can fetch them as fixed-output derivations (network allowed
      # under sandboxing because the content hash is known upfront) instead
      # of needing `typst compile` itself to reach the network.
      typstPackages = [
        { name = "altacv"; version = "1.5.0"; hash = "sha256-9mT79OTp47a0grwQeP2gUU9t3qVh1MB+TzOhSERpL+Q="; }
        { name = "fontawesome"; version = "0.6.1"; hash = "sha256-tYw/l43OEamaMQoOYU5QxOOA9a1pS4ReiLmHbGa6JoM="; }
        { name = "zebra"; version = "0.1.0"; hash = "sha256-qyK88R64meheKEg9bAuCtHOifNUqgG3BHrG35NJjAko="; }
        { name = "gairm-import"; version = "0.8.1"; hash = "sha256-FGxwc/a7Jq29jjBvNtkuR7JcSkmJg9CULQ5IWSzzY/k="; }
      ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Assembles the fetched packages into the directory layout Typst
          # expects under its cache dir: <cache>/typst/packages/preview/<name>/<version>/
          typstPackageCache = pkgs.runCommand "typst-package-cache" { } (
            "mkdir -p $out/preview\n" +
            pkgs.lib.concatMapStrings
              (p: ''
                mkdir -p "$out/preview/${p.name}"
                ln -s ${pkgs.fetchzip {
                  url = "https://packages.typst.org/preview/${p.name}-${p.version}.tar.gz";
                  hash = p.hash;
                  stripRoot = false;
                }} "$out/preview/${p.name}/${p.version}"
              '')
              typstPackages
          );
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "cv";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [ pkgs.typst ];
            TYPST_FONT_PATHS = "${pkgs.font-awesome}/share/fonts:${pkgs.lato}/share/fonts";

            buildPhase = ''
              runHook preBuild

              export HOME="$TMPDIR"
              mkdir -p "$HOME/.cache/typst"
              ln -s ${typstPackageCache} "$HOME/.cache/typst/packages"

              typst compile cv.typ resume.pdf
              typst compile cv.typ resume-ATS.pdf --input columnRatio=1

              mkdir -p variants
              for variant in variants/*.yaml; do
                [ -s "$variant" ] || continue
                name="$(basename "$variant" .yaml)"
                typst compile cv.typ "variants/resume-$name.pdf" --input fileName="$variant"
                typst compile cv.typ "variants/resume-$name-ATS.pdf" --input fileName="$variant" --input columnRatio=1
              done

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/variants
              cp resume.pdf resume-ATS.pdf $out/
              cp variants/resume-*.pdf $out/variants/
              runHook postInstall
            '';
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.typst ];
            TYPST_FONT_PATHS = "${pkgs.font-awesome}/share/fonts:${pkgs.lato}/share/fonts";
          };
        });
    };
}
