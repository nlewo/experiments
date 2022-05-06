# Intro

Goto [0-evaluation.nix](./0-evaluation.nix)

    nix-instantiate --eval --strict 0-evaluation.nix --json | jq .

Expressions proposed in the rest of this document should not be used
in real life: there are only an educational material.

# Overview of a Nix build

Nix expression ->           Derivation              -> Artifact
 my-expr.nix   -> /nix/store/hash-my-derivation.drv -> /nix/store/hash-my-artifact

# What is a derivation

Goto [1-derivation.nix](./1-derivation.nix)

- To instantiate the derivation: `nix-instantiate 1-derivation.nix`
- To realize the derivation: `nix-store --realize /nix/store/...empty.drv`

# Actually, we use stdenv.mkDerivation

Goto [2-mk-derivation.nix](2-mk-derivation.nix)

See https://nixos.org/manual/nixpkgs/stable/#chap-stdenv

# And more often, wrappers on mkDerivation

Goto [3-run-command.nix](3-run-command.nix)

- Trivial builders: `writeTextFile`, `runCommand`, `writeScript`, ...
  See https://nixos.org/manual/nixpkgs/stable/#chap-trivial-builders
- Language builders: `buildPythonPackage`, `buildGoModule`, ...
  See https://nixos.org/manual/nixpkgs/stable/#chap-language-support
- Image builders: `dockerTools.buildImage`
  See https://nixos.org/manual/nixpkgs/stable/#chap-images


# Path allocation by reference

Goto [4-path-allocation.nix](4-path-allocation.nix)


# How could i do something more useful, such as getting a file from Internet?

Goto [5-fixed-output-derivation.nix](5-fixed-output-derivation.nix)

# There are simpler ways to fetch artifact from Internet

Goto [6-fetcher.nix](6-fetcher.nix)


# Wait, how nixpkgs is pinned?

It was not, and we should never do that, excepting to make expressions
easier to read for learning sessions!

Goto [7-nixpkgs-pinned.nix](7-nixpkgs-pinned.nix)


# Let's build a Python package

Goto [8-python-package.nix](8-python-package.nix)

# And pack it into a Docker image
Goto [9-docker-image.nix](9-docker-image.nix)


# Some not covered elements

- binary caches
- enter to the build environment, ie nix-shell
- flakes



# Still time/energy to practice?
## Write a Nix expression evaluating returning a docker compose file
- expected result
```
      nix-instantiate --eval --strict docker-compose.nix --json | jq .
      {
          "services": {
              "helloworld": {
                  "command": [
                      "-listen",
                      ":5678",
                      "-text",
                      "hello world"
                  ],
                  "image": "hashicorp/http-echo",
                  "ports": [
                      "8080:5678"
                  ]
              }
          },
          "version": "3"
      }
```

## Make this Nix expression generating the docker-compose file
- Use the `writeTextFile` function from nixpkgs
  https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeText
- `builtins.toJSON` takes an object
- To build something, we have to use `nix-build file.nix`
- hint: to use nixpkgs, add `pkgs = import <nixpkgs> {}`

## instantiate VS realize
- `nix-build` does several things:
- `nix-instantiate` evaluate Nix expressions and generate derivations
- `nix-store -r` realize a derivation

## Build a script to run docker-compose
- Build a script to run `docker-compose -f our-docker-compose-file.json`
- Use `pkgs.writeScript`
- Expected output:
  ```
    $ nix-build workshop.nix
    ./result
    Define and run multi-container applications with Docker.
    ...
  ```
- Welcome to the nice nixpkgs documentation:
  https://github.com/NixOS/nixpkgs/blob/780270a2cffa83a74c6038f20762e3966c129bca/pkgs/build-support/trivial-builders.nix#L184
- What are the dependencies
