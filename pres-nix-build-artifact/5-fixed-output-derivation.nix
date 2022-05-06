let
  pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "internet";
  dontUnpack = true;

  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = "sha256-6qM2U/06tELzEb6Yg9FwCRL1yzXl012Y5XI9Z+aVxOM=";
  SSL_CERT_FILE = "${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt";

  installPhase = "${pkgs.curl}/bin/curl -o $out https://raw.githubusercontent.com/Gandi/awesome-gandi/main/README.md";
}
