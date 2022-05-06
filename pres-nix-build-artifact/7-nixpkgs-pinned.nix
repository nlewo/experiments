let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a38cde9e464bd5562b51a6466463ac9fa0eb242f.tar.gz";
    sha256 = "0whw76saqnfij4zz3jmbgc1zqxqm3cvyz96sb7ldxbylpldsf54g";
  };
  pkgs = import nixpkgs {};
in {
  hello = pkgs.hello;
  nixpkgsPath = pkgs.runCommand "nixpkgs-path" {} "echo ${nixpkgs} > $out";
}

# In practice, we use Niv or Flakes to pin inputs.
