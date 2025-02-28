set -o xtrace

export ANVIL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export CONTRACT_PATH=espresso-app/src/Counter.sol
export CONTRACT_NAME=Counter
export ANVIL_SOURCE_CHAIN_RPC_URL=http://localhost:8545
export ANVIL_DESTINATION_CHAIN_RPC_URL=http://localhost:8546

forge create --rpc-url  $ANVIL_SOURCE_CHAIN_RPC_URL --private-key $ANVIL_PRIVATE_KEY  "$CONTRACT_PATH:$CONTRACT_NAME" --broadcast
forge create --rpc-url $ANVIL_DESTINATION_CHAIN_RPC_URL --private-key $ANVIL_PRIVATE_KEY  "$CONTRACT_PATH:$CONTRACT_NAME" --broadcast
