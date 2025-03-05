export CONTRACT_PATH=espresso-app/src/Counter.sol
export CONTRACT_NAME=Counter

forge create --rpc-url  $SOURCE_CHAIN_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY  "$CONTRACT_PATH:$CONTRACT_NAME" --broadcast --json > $ESPRESSO_APP_CONTRACTS_DATA_FILE_SOURCE
forge create --rpc-url $DESTINATION_CHAIN_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY  "$CONTRACT_PATH:$CONTRACT_NAME" --broadcast --json > $ESPRESSO_APP_CONTRACTS_DATA_FILE_DESTINATION

export SOURCE_APP_ADDRESS=`jq -r ".deployedTo" $ESPRESSO_APP_CONTRACTS_DATA_FILE_SOURCE`
export DESTINATION_APP_ADDRESS=`jq -r ".deployedTo" $ESPRESSO_APP_CONTRACTS_DATA_FILE_DESTINATION`

echo "Espresso app contract successfully deployed on the source chain at address $SOURCE_APP_ADDRESS."
echo "Espresso app contract successfully deployed on the destination chain at address $DESTINATION_APP_ADDRESS."
