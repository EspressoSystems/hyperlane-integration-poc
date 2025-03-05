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
            export HYP_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
            export DEPLOYER_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
            export DEPLOYER_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
            export RPC_SOURCE_CHAIN_PORT=8545
            export RPC_DESTINATION_CHAIN_PORT=8546
            export SOURCE_CHAIN_RPC_URL=http://localhost:$RPC_SOURCE_CHAIN_PORT
            export DESTINATION_CHAIN_RPC_URL=http://localhost:$RPC_DESTINATION_CHAIN_PORT
            export ESPRESSO_APP_CONTRACTS_DATA_FILE_SOURCE=/tmp/source_espresso_app_deploy.json
            export ESPRESSO_APP_CONTRACTS_DATA_FILE_DESTINATION=/tmp/destination_espresso_app_deploy.json
            export CHAIN_NAME=source
            export SOURCE_CHAIN_ID=31337
            export DESTINATION_CHAIN_ID=31338
          '';
        };
      });
}
