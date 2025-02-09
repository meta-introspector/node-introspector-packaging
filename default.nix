{ stdenv, callPackage, tree, system, ...
}:
with stdenv;
let
  deps = mkDerivation {
    name = "test";
    version = "0.0.1";
    src = ./.;
    buildPhase = ''
    '';
    installPhase = ''
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
#    outputHash = "sha256-7kJTNEcKby9JJN5Q4lrdguvia0MynYhdGNGwgSNY7Ds=";
  };

  backend = mkDerivation {
    name = "test";
    src = ./.;
    buildInputs = [  ];
    buildPhase = ''
    '';
    installPhase = ''
    '';
  };
  frontend = (callPackage ./node/webapp/default.nix { }).shell;

in frontend
