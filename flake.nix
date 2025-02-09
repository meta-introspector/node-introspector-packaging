{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
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

  outputs = { self, nixpkgs, flake-utils, devshell, npmlock2nix, gitignore }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system; 
          overlays = [
            devshell.overlay
            (final: prev: {
              npmlock2nix = import npmlock2nix { pkgs = prev; };
                          })
          ];
         config.allowUnfree = true;
        };
        inherit (pkgs) lib;

        # Assuming you have one or more npm packages in your repository
        npmPackages = {
          # Example package
          #my-package = {
            #src = ./my-package;
            # If you're not using npmlock2nix, you might have to specify package.json manually here
          #};
          # Add more packages as needed
        };

        # Function to build an npm package using npmlock2nix
        buildNpmPackage = name: package: 
          pkgs.npmlock2nix.v2.package {
            inherit (package) src;
            pname = name;
            version = "1.0.0"; # You might want to dynamically read this from package.json
            node_modules_attrs = {
              # Additional attributes for node_modules if needed
            };
          };

        # Create packages for each npm package defined
        packages = builtins.mapAttrs buildNpmPackage npmPackages;

      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_23
            pkgs.nodePackages.pnpm
            pkgs.nodePackages.typescript
            pkgs.nodePackages.typescript-language-server
          ];
        };
        # Expose the packages for use outside the flake
        packages = packages // {
          #default = packages.my-package; # or whichever package you want as default
        };
      }
    );
}


      #   in {
      #   packages = {
      #     default = pkgs.callPackage ./default.nix { };
      #     front-end = pkgs.npmlock2nix.build {
      #       src = ./node/webapp;
      #       installPhase = "cp -r ../src/main/resources/static $out";
      #       buildCommands = [ "npm run build" ];
      #       node_modules_attrs = { nativeBuildInputs = [ pkgs.python2 ]; };
      #     };

      #   };
      #   devShell = pkgs.devshell.mkShell {
      #     env = [
      #       {
      #         name = "JAVA_HOME";
      #         value = "${pkgs.openjdk8}";
      #       }
      #       {
      #         name = "NIX_LD_LIBRARY_PATH";
      #         value = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ];
      #       }
      #       {
      #         name = "NIX_LD";
      #         value = builtins.readFile
      #           "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
      #       }
      #     ];
      #     commands = [
      #       {
      #         category = "Programming language support";
      #         package = pkgs.openjdk8;
      #         help = ''
      #           1. use gradle assemble to install dependency first
      #                         2. use gradle build -x test for dev build 
      #                         3. go to node/build/lib to find jars 
      #         '';
      #       }
      #       {
      #         category = "Java package manager";
      #         package = pkgs.gradle.override { java = pkgs.openjdk8; };
      #         name = "gradle";
      #         help = ''
      #           1. use gradle assemble to install dependency first
      #                         2. use gradle build -x test for dev build 
      #                         3. go to node/build/lib to find jars 
      #         '';
      #       }
      #       {
      #         category = "Java package manager";
      #         package = pkgs.nodejs-14_x;
      #         name = "nodejs";
      #       }
      #       { package = pkgs.python2; }
      #     ];
      #   };
      # });
