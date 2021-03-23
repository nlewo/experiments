# How to create poetry files
#
# $ nix shell github:NixOS/nixpkgs/nixos-20.09#python3Packages.virtualenv github:NixOS/nixpkgs/nixos-20.09#gcc github:NixOS/nixpkgs/nixos-20.09#poetry
# $ virtualenv /tmp/venv
# $ source /tmp/venv/bin/activate
# $ pip install openstackclient
# $ poetry init -n
# $ pip freeze | xargs poetry add
# # manually add setuptools_rust = "0.11.4" in pyproject.toml (required by cryptography)
# $ poetry update

let
  pkgs = (builtins.getFlake "github:nixos/nixpkgs?rev=462c6fe4b115804ea4d5bee7103c0f46ff9f9cfb").legacyPackages.x86_64-linux;
  openstackEnv = pkgs.poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    python = pkgs.python38;
    overrides = pkgs.poetry2nix.overrides.withDefaults (self: super: {

  cryptography = super.cryptography.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ self.setuptools-rust ];
      buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.openssl ];
      CRYPTOGRAPHY_DONT_BUILD_RUST=1;
    });

    munch = super.munch.overridePythonAttrs (
      old: {
        propagatedBuildInputs = [ self.pbr self.six ];
      }
    );

    python-swiftclient = super.python-swiftclient.overridePythonAttrs (
      old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.pbr ];
      }
    );

    requestsexceptions = super.requestsexceptions.overridePythonAttrs (
      old: {
        propagatedBuildInputs = [ self.pbr ];
      }
    );

      pbr = super.pbr.overridePythonAttrs(
        old: {
          # This is because pbr relies on pkgs_resource (provided by setuptools)
          prePatch = ''substituteInPlace pbr/version.py --replace 'self.semantic_version().brief_string()' '"${self.python-openstackclient.version}"' '';
        });
    });
  };
    
in pkgs.writers.writeBashBin "openstack" "${openstackEnv}/bin/python -c 'import openstackclient.shell; openstackclient.shell.main()' $@"
