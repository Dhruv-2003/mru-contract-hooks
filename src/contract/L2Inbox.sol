// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {IMessageRecipient} from "./interfaces/IMessageRecipient.sol";

/**
 * @title L2Inbox
 * This contract is a L2 inbox that stores the currentStateRootHash & is updated via the Hook through Bridges
 */
contract L2Inbox is IMessageRecipient {
    bytes32 public currentStateRoot;

    address public mailbox;

    /**
     * modifier to check if the sender is the mailbox
     */
    modifier onlyMailbox() {
        require(
            msg.sender == address(mailbox),
            "MailboxClient: sender not mailbox"
        );
        _;
    }

    constructor() {
        mailbox = 0x6966b0E55883d49BFB24539356a2f8A673E02039;
    }

    /**
     * to handle the message from the origin chain
     * @dev called by the Hyperlane Mailbox
     */
    function handle(
        uint32,
        bytes32,
        bytes calldata _message
    ) external payable onlyMailbox {
        bytes32 rootHash = abi.decode(_message, (bytes32));
        setStateRootHash(rootHash);
    }

    /**
     * Set State Root hash
     * @dev called by the L1-L2 messenger
     * @notice only Owner/Operator should be authorised , but cu
     * @param _newStateRoot current state root for the keystore
     */
    function setStateRootHash(
        bytes32 _newStateRoot
    ) public returns (bytes32 stateRoot) {
        currentStateRoot = _newStateRoot;

        return currentStateRoot;
    }

    // Returns the Current state root hash
    function getCurrentStateRootHash() public view returns (bytes32) {
        return currentStateRoot;
    }
}
