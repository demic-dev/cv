{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    typst
  ];

  shellHook = ''
    echo "Compiling..."
    typst compile cv.typ michele-de-cillis_cv.pdf
    echo "Done!"
    exit 0
  '';
}
