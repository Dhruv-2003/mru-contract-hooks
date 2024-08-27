// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

/**
 * @title L2Inbox
 * This contract is a L2 inbox that stores the currentStateRootHash & is updated via the Hook through native Bridges
 * @notice The setStateRootHash function is not restricted currently to any specific sender , but ideally should be the L1-L2 messenger
 */
contract L2Inbox {
    bytes32 public currentStateRoot;

    /**
     * Set State Root hash
     * @dev called by the L1-L2 messenger
     * @notice only Owner/Operator are authorised
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
