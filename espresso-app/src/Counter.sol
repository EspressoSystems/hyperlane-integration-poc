// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";
import "../lib/hyperlane-monorepo/solidity/contracts/interfaces/IMessageRecipient.sol";

contract Counter {
    uint256 public number;

    // This address is the same on both chains.Ok for now. TODO fetch from "configs/config.json"
    address constant mailboxAddress = 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    // Send message from source chain to destination chain
    function sendMessage(address appDestinationAddress) public returns (bytes32) {
        // Hardcoded values. Ok for now.  TODO fetch from "configs/config.json"
        uint32 destinationChainId = 31338;

        IMailbox mailbox = IMailbox(mailboxAddress);
        bytes32 appDestinationAddressBytes32 = addressToBytes32(appDestinationAddress);
        bytes32 messageId = mailbox.dispatch(destinationChainId, appDestinationAddressBytes32, bytes("Hello, world"));

        return messageId;
    }

    // Utility function
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /// Logic for receiving a message

    // For access control on handle implementations
    modifier onlyMailbox() {
        require(msg.sender == mailboxAddress);
        _;
    }

    function handle(uint32 _origin, bytes32 _sender, bytes calldata _body) external onlyMailbox {
        // Just increment the local counter when receiving the message
        number++;
    }
}
