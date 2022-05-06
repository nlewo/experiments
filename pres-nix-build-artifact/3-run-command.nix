let
  pkgs = import <nixpkgs> {};
in
{
  runCommand = pkgs.runCommand "empty-run-command" {} "echo > $out";
  writeFile = pkgs.writeTextFile {
    name = "empty-writeFile";
    text = "";
  };
}
