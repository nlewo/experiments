let
  pkgs = import <nixpkgs> {};
in
rec {
  content = pkgs.writeTextFile {
    name = "my-content";
    text = "This is my content";
  };
  extendedContent = pkgs.runCommand "extended" {} ''
    echo Extended > $out
    cat ${content} >> $out
  '';
  extendedAtRuntime = pkgs.writeScript "extended-script" ''
    echo Extended
    cat ${content}
  '';
}

# Show build VS runtime deps
