let
  pkgs = import <nixpkgs> {};
in {
  fetchurl = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Gandi/awesome-gandi/main/README.md";
    sha256 = "sha256-6qM2U/06tELzEb6Yg9FwCRL1yzXl012Y5XI9Z+aVxOM=";
  };

  fetchFromGitHub = pkgs.fetchFromGitHub {
    owner = "gandi";
    repo = "awesome-gandi";
    rev = "74c873d8de4eec1d5d03d502e546df6d1806c1ef";
    sha256 = "sha256-5wHTRLFRha7+fGAHCH4ZwVPuFnBOaiRSpATqsv4nC64=";
  };
}
