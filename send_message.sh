# Calls Counter.sendMessage(destination) function

set -o xtrace

export ANVIL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export DESTINATION_APP_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3 #TODO obtain from the deploy script
export MAILBOX_ADDRESS=0x8A791620dd6260079BF849Dc5567aDC3F2FdC318 # TODO obtain from configs/config.json
cast send $MAILBOX_ADDRESS "sendMessage((address))" "($DESTINATION_APP_ADDRESS)" --private-key $ANVIL_PRIVATE_KEY
