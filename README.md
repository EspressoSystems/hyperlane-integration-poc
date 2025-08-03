# Espresso Hyperlane Integration

### The following README is currently being updated; it may not reflect the most up to date changes, or may have duplications. 

## Setup

Install the Hyperlane CLI: `npm install -g @hyperlane-xyz/cli` 

In another terminal run the command below to launch the source chain:
`./scripts/launch_source_chain.sh`
In another terminal run the command below to launch the destination chain:
`./scripts/launch_destination_chain.sh`

Hyperlane contracts are pre-deployed on each chain.  Each chain uses a unique seed to generate different addresses to reduce bugs caused by sharing the default addresses across chains.  If you want to update the seed, be sure to also update `.hyperlane.env` with the new pre-funded addresses. 


## Deploy Hyperlane contracts
Note: The above scripts will start Anvil nodes with *pre-deployed* Hyperlane contracts. The Hyperlane contracts only need to be deployed to fresh Anvil chains or (potentiall) forks of live chains.

### Deploy Registries

See the Hyperlane [docs](https://docs.hyperlane.xyz/docs/guides/quickstart/local-testnet-setup) for additional detail about deploying their contracts. 

For an initial dev environment, we will use the same address and private key to keep things simple. 

hyperlane registry init --private-key $HYP_KEY

hyperlane registry init --private-key $HYP_KEY

This will create a hyperlane registry in your home directory at `.hyperlane/`. Copy this directory into the `.hyperlane` directory in this repo to allow others to reproduce your deployment. 

NOTE: All calls to the Hyperlane CLI from now on will need to specify `--registry ./hyperlane`.  This tells the CLI to point to the registry in this repo instead of the user's local registry.  


### Deploy Core Contracts
NOTE: You can deploy core contracts without remaking the chain registries.  

hyperlane core init --private-key $HYP_KEY --advanced --registry .hyperlane

See configs/core-config.yaml for the options to select

We use the trustedRelayer ISM for development to make things simple. 

We set the default hook to the InterchainGasPaymaster.  Default hooks can be overriden.  Most of the time we will want to use the IGP hook.  

We set the required hook to the MerkleTeeHook.  Any multisig ISM (ours is a multisig secured by a TEE) requires this hook.  

We use the first Anvil address for all signers.  

The relayer address on the destiation chain must match the signer on the source chain for the trustedRelayer ISM. 

All other options are defaults. 

Do the following on each chain

hyperlane core deploy --private-key $HYP_KEY --registry .hyperlane

Run 
hyperlane send message --relay  --registry .hyperlane 
To test the deployment

hyperlane warp init --advanced  --registry .hyperlane

hyperlane warp deploy  --registry .hyperlane

hyperlane warp send --relay --symbol ETH  --registry .hyperlane