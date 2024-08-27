// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {IBaseHook} from "./interfaces/IBaseHook.sol";
import {IAppInbox} from "./interfaces/IAppInbox.sol";
import {ICrossDomainMessenger} from "./interfaces/ICrossDomainMessenger.sol";

import {L2Inbox} from "./L2Inbox.sol";

contract Hook is IBaseHook {
    ICrossDomainMessenger public optimismMessenger;
    address public L2InboxAddress;

    constructor(address _l2InboxAddress) {
        optimismMessenger = ICrossDomainMessenger(
            address(0x58Cc85b8D04EA49cC6DBd3CbFFd00B4B8D6cb3ef)
        );
        L2InboxAddress = _l2InboxAddress;
    }

    function postSubmit(
        IAppInbox.Batch calldata _batch,
        address
    ) external override {
        // Get the state root of the last block in that batch
        bytes32 stateRoot = _batch.lastBlock.stateRoot;

        // Send the state root to the optimism bridge
        sendRootToOptimism(stateRoot);
    }

    function sendRootToOptimism(bytes32 _rootHash) public payable {
        bytes memory data = abi.encodeCall(
            L2Inbox.setStateRootHash,
            (_rootHash)
        );
        optimismMessenger.sendMessage(L2InboxAddress, data, 200000);
    }
}
