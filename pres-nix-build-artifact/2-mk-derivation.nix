let
  pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "empty";
  dontUnpack = true;
  installPhase = "echo > $out";
}

# show the hello derivation
