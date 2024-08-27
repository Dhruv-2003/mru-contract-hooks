// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IAppInbox {
    /*/////////////////// DATA //////////////////////////////*/

    struct AppData {
        bytes32 stateMachineHash;
        bytes32 genesisStateHash;
    }

    struct BlockHeader {
        bytes32 blockHash;
        bytes32 parentHash;
        bytes32 actionRoot;
        bytes32 acknowledgementRoot;
        bytes32 stateRoot;
        bytes32 hooksRoot;
        uint256 height;
        uint256 timestamp;
        bytes vulcanLeaderSignature;
        bytes operatorSignature;
        bytes builderSignature;
        uint256 executionStatus;
    }

    struct BlobPointer {
        bytes blobID; // The ID of the blob
        DAProvider da; // The DA layer where the blob is stored
    }

    enum DAProvider {
        AVAIL,
        CELESTIA
    }

    struct Batch {
        uint256 appId;
        bytes32 blocksRoot; // Commitment to underlying blocks
        uint32 sequenceNumber; // Index of the batch in the sequence
        uint32 width; // Number of blocks in the batch
        bytes32 batchRoot; // Commitment to batch. batchRoot = keccak(blocksRoot, height, width)
        bytes signature; // signature of the batchRoot
        BlobPointer daPointer; // Pointer to batch data on DA layer
        BlockHeader firstBlock;
        BlockHeader lastBlock;
    }

    struct BatchHeader {
        bytes32 batchRoot;
        bytes32 blocksRoot;
        BlobPointer daPointer;
        uint256 lastBlockHeight; // Height of the last block in the batch
        bytes32 lastBlockHash; // Hash of the last block in the batch
        bytes32 stateRoot; // Commitment to the state of the last block in the batch aka latest state
    }

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event BatchSubmitted(
        uint256 indexed batchHeight,
        bytes32 indexed batchRoot,
        uint256 indexed lastBlockHeight,
        uint256 firstBlockHeight,
        bytes32 stateRoot
    );

    event TicketCreated(
        uint256 indexed ticketNumber,
        address indexed sender,
        bytes32 indexed identifier,
        bytes message
    );

    event RegisteredSTF(
        bytes32 stateMachineHash,
        bytes32 genesisStateHash,
        address operator
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function submit(Batch calldata _batch, address _submitter) external;
}
