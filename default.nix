  {pkgs ? import <nixpkgs> {
    inherit system;
  }, system ? builtins.currentSystem, nodejs ? pkgs."nodejs-23_x"}:

  let
  nodeEnv = import ./node-env.nix {
    inherit (pkgs) stdenv lib runCommand writeTextFile writeShellScript;
    inherit pkgs nodejs;
    libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
  };

# { stdenv, callPackage, tree, system, ...
# }:
# with stdenv;
# let
#   deps = mkDerivation {
#     name = "test";
#     version = "0.0.1";
#     src = ./.;
#     buildPhase = ''
#     '';
#     installPhase = ''
#     '';
#     outputHashAlgo = "sha256";
#     outputHashMode = "recursive";
# #    outputHash = "sha256-7kJTNEcKby9JJN5Q4lrdguvia0MynYhdGNGwgSNY7Ds=";
#   };

#   backend = mkDerivation {
#     name = "test2";
#     src = ./.;
#     buildInputs = [  ];
#     buildPhase = ''
#     '';
#     installPhase = ''
#     '';
#   };
#   ## frontend = (callPackage ./node/webapp/default.nix { }).shell;

# in backend

in
import ./node-packages.nix {
  inherit (pkgs) fetchurl nix-gitignore stdenv lib fetchgit;
  inherit nodeEnv;
}
