# Calls Counter.sendMessage(destination) function
export SOURCE_APP_ADDRESS=`jq -r ".deployedTo" $ESPRESSO_APP_CONTRACTS_DATA_FILE_SOURCE`
export DESTINATION_APP_ADDRESS=`jq -r ".deployedTo" $ESPRESSO_APP_CONTRACTS_DATA_FILE_DESTINATION`


cast send $SOURCE_APP_ADDRESS "sendMessage(address)" "$DESTINATION_APP_ADDRESS" --private-key $DEPLOYER_PRIVATE_KEY --rpc-url=$SOURCE_CHAIN_RPC_URL
echo "Sending message to $DESTINATION_APP_ADDRESS on destination chain..."
