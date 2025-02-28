# Calls Counter.sendMessage(destination) function

set -o xtrace

export ANVIL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export SOURCE_APP_ADDRESS=0x4A679253410272dd5232B3Ff7cF5dbB88f295319 #TODO obtain from the deploy script
export DESTINATION_APP_ADDRESS=0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f #TODO obtain from the deploy script
export SOURCE_RPC_URL=http://localhost:8545
cast send $SOURCE_APP_ADDRESS "sendMessage(address)" "$DESTINATION_APP_ADDRESS" --private-key $ANVIL_PRIVATE_KEY --rpc-url=$SOURCE_RPC_URL
