#!/bin/bash
set -e

cast send  $HYP_ADDRESS --value 1ether --private-key $CAFF_NODE_DEV_PRIV_KEY --rpc-url $SOURCE_CHAIN_RPC_URL > /dev/null

echo "Hyperlane address $HYP_ADDRESS  on source chain funded correctly."


cast send  $RELAYER_ADDRESS --value 1ether --private-key $HYP_KEY --rpc-url $DESTINATION_CHAIN_RPC_URL > /dev/null
echo "Relayer address $RELAYER_ADDRESS  on destination chain funded correctly."


cast send  $VALIDATOR_ADDRESS --value 1ether --private-key $CAFF_NODE_DEV_PRIV_KEY --rpc-url $SOURCE_CHAIN_RPC_URL > /dev/null
echo "Validator address $VALIDATOR_ADDRESS  on source chain funded correctly."
