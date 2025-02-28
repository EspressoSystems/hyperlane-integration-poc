export DESTINATION_APP_ADDRESS=0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f #TODO obtain from the deploy script
cast call $DESTINATION_APP_ADDRESS "number()" --rpc-url=http://localhost:8546
