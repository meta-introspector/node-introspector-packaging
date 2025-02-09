{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    npmlock2nix = {
      # url = "github:nix-community/npmlock2nix/master";
      # flake = false;
      url = "github:Luis-Domenech/npmlock2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

#   outputs = { self, nixpkgs, flake-utils,  npmlock2nix, gitignore }:
#     #  [ "x86_64-linux" ]
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = import nixpkgs { 
#           inherit system; 
#           overlays = [
#             (final: prev: {
#               npmlock2nix = import npmlock2nix { pkgs = prev; };
#                           })
#           ];
#          config.allowUnfree = true;
#         };
#         inherit (pkgs) lib;

#         # Assuming you have one or more npm packages in your repository
#         npmPackages = {
#           # Example package
#           #my-package = {
#             #src = ./my-package;
#             # If you're not using npmlock2nix, you might have to specify package.json manually here
#           #};
#           # Add more packages as needed
#         };

#         # Function to build an npm package using npmlock2nix
#         buildNpmPackage = name: package: 
#           pkgs.npmlock2nix.v2.package {
#             inherit (package) src;
#             pname = name;
#             version = "1.0.0"; # You might want to dynamically read this from package.json
#             node_modules_attrs = {
#               # Additional attributes for node_modules if needed
#             };
#           };

#         # Create packages for each npm package defined
#         packages = builtins.mapAttrs buildNpmPackage npmPackages;

#       in {
#         devShell = pkgs.mkShell {
#           buildInputs = [
#             pkgs.nodejs_23
#             pkgs.nodePackages.pnpm
#             pkgs.nodePackages.typescript
#             pkgs.nodePackages.typescript-language-server
#           ];
#         };
#         # Expose the packages for use outside the flake
#         packages = {
#               default = pkgs.callPackage ./default.nix { };
#               front-end = pkgs.npmlock2nix.build {
#                 #src = ./node/webapp;
#                 #       installPhase = "cp -r ../src/main/resources/static $out";
#                 #       buildCommands = [ "npm run build" ];
#                 #       node_modules_attrs = { nativeBuildInputs = [ pkgs.python2 ]; };
#               };
#       };
#       });
# }

   outputs = { self, nixpkgs, flake-utils,  npmlock2nix, gitignore }:
    let
      supportedSystems = [ "x86_64-linux"
                           #"aarch64-darwin" "x86_64-darwin"
                           "aarch64-linux" ];
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      npmlock2nixSrc = pkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "npmlock2nix";
        tag = "main";
      };
      npmlock2nix = import npmlock2nixSrc { inherit pkgs; };
    in
    {
      packages."x86_64-linux".default = npmlock2nix.v2.build {
        src = ./.;
        nodejs = pkgs.nodejs-18_x;
        installPhase = "cp -r dist $out";
        buildCommands = [ "npm run build" ];
      };
    };
}
