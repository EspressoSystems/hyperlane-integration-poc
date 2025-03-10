# flake.nix
{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    foundry.url = "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases

  };

  outputs = { self, nixpkgs, utils, foundry }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
        };
      in {

        devShell = with pkgs; mkShell {
          buildInputs = [
            # From the foundry overlay
            # Note: Can also be referenced without overlaying as: foundry.defaultPackage.${system}
            foundry-bin
            nodejs-18_x
            nodePackages.pnpm
            awscli2
            pkgs.terraform
            # ... any other dependencies we need
            solc
          ];

          # Decorative prompt override so we know when we're in a dev shell
          shellHook = ''
            pnpm i
            export PATH="$PATH:$(pwd)/node_modules/.bin:$(pwd)/scripts"
            export FOUNDRY_DISABLE_NIGHTLY_WARNING=true
            source .hyperlane.env
          '';
        };
      });
}
