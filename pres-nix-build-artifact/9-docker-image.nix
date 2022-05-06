let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a38cde9e464bd5562b51a6466463ac9fa0eb242f.tar.gz";
    sha256 = "0whw76saqnfij4zz3jmbgc1zqxqm3cvyz96sb7ldxbylpldsf54g";
  };
  pkgs = import nixpkgs {};

  datashape = import ./python-package.nix;
in pkgs.dockerTools.buildImage {
  name = "datashape";
  config.entrypoint = "${datashape.interpreter}/bin/python";
}
