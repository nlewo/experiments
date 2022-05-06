let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a38cde9e464bd5562b51a6466463ac9fa0eb242f.tar.gz";
    sha256 = "0whw76saqnfij4zz3jmbgc1zqxqm3cvyz96sb7ldxbylpldsf54g";
  };
  pkgs = import nixpkgs {};

in rec {

  datashape = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "datashape";
    version = "0.4.7";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "14b2ef766d4c9652ab813182e866f493475e65e558bed0822e38bf07bba1a278";
    };

    doCheck = false;
    propagatedBuildInputs = with pkgs.pythonPackages; [ numpy multipledispatch python-dateutil ];
  };

  interpreter = pkgs.python.withPackages (_: [datashape]);
}
