// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {IBaseHook} from "./interfaces/IBaseHook.sol";
import {IAppInbox} from "./interfaces/IAppInbox.sol";
import {ICrossDomainMessenger} from "./interfaces/ICrossDomainMessenger.sol";
import {IMailbox} from "./interfaces/IMailbox.sol";

import {TypeCasts} from "./lib/TypeCasts.sol";

import {L2Inbox} from "./L2Inbox.sol";

/**
 * @title Hook
 * This contract is a hook implementation that sends the stateRoot to the L2Inbox via message bridging
 */
contract Hook is IBaseHook {
    using TypeCasts for address;
    using TypeCasts for bytes32;

    IMailbox public immutable mailbox;
    uint32 public immutable BRIDGE_DOMAIN = 11155420; // Optimism sepolia domain
    uint32 public constant MRU_DOMAIN = 11155111; // Sepolia domain (MRU)

    address public L2InboxAddress;

    constructor(address _l2InboxAddress) {
        mailbox = IMailbox(0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766); // for Sepolia mailbox
        L2InboxAddress = _l2InboxAddress;
    }

    /**
     * post submit Hook that is called after the batch is submitted
     * @param _batch the batch that was submitted
     */
    function postSubmit(
        IAppInbox.Batch calldata _batch,
        address
    ) external override {
        // Get the state root of the last block in that batch
        bytes32 stateRoot = _batch.lastBlock.stateRoot;

        // Send the state root to the optimism bridge
        // sendRootToOptimism(stateRoot);
        sendRootToOptimismViaHyperlane(stateRoot);
    }

    /**
     * Send the state root to the L2Inbox
     * @param _rootHash the root hash to send
     */
    function sendRootToOptimismViaHyperlane(bytes32 _rootHash) public {
        // Get a fee quote for the message
        uint256 fee = quoteSendRoot(_rootHash);

        // check is the contract has enough balance to pay the fee
        if (address(this).balance >= fee) {
            // Send the message to the mailbox
            mailbox.dispatch{value: fee}(
                BRIDGE_DOMAIN,
                TypeCasts.addressToBytes32(L2InboxAddress),
                abi.encode(_rootHash)
            );
        }
    }

    /**
     & quoteSendRoot to get the fee for sending the root hash to the L2Inbox
     * @param _rootHash the root hash to send
     */
    function quoteSendRoot(
        bytes32 _rootHash
    ) public view returns (uint256 fee) {
        fee = mailbox.quoteDispatch(
            BRIDGE_DOMAIN,
            TypeCasts.addressToBytes32(L2InboxAddress),
            abi.encode(_rootHash)
        );
    }

    // to receive ether
    receive() external payable {}
}
