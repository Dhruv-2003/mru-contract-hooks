# Using contract hooks for a Stackr Micro Rollup

## Overview

This guide provides basic instructions for utilizing contract hooks for a Stackr Micro Rollups (MRU) using a hook contract. This setup allows you to perform actions when a batch is submitted by the vulcan operator to the MRU's AppInbox contract.

In this example, the latest stateRootHash of the latest blocks is being sent to an Inbox on L2 i.e. optimism sepolia using a GMP bridge like Hyperlane.

## Prerequisites

Before you begin this tutorial, please ensure you go through the following:

- Basic understanding of the Stackr Micro rollup framework: [Zero to One](/build/zero-to-one/getting-started)
- Familiarity with Solidity and smart contract deployment

## How to use Hooks ?

### Step 1 Creating up the hook contracts

Once you have your MRU setup ready with a template of your choice, Start by creating a hooks contract by inheriting the `IBaseHook.sol`.

Then define the logic for the function `postSubmit` to perform the action you want to with the `_batch` data and `_submitter` address.

```solidity
 contract Hook is IBaseHook {
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

        // Send the state root
        sendRootToOptimismViaHyperlane(stateRoot);
    }
}
```

In this case, we utilize the Hyperlane Message bridge to send the state root from the `Sepolia` chain where the Appinbox to `Optimism Sepolia` where the `L2Inbox` will be deployed. We prepare the message by encoding it and also handling the fees payment for the bridging on both origin & destination chain.

```solidity
 contract Hook is IBaseHook {
    ....

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

    ....
}
```

Similarly we have a simple contract on the L2 called `L2Inbox` which keeps the record of the latest state root hash on the L2 chains. You can refer the contract [here](https://github.com/Dhruv-2003/mru-contract-hooks/blob/main/src/contract/L2Inbox.sol)

### Step 2 Adding the hook to appInbox

Once the contracts are deployed on both the chains, we have to add the Hook contract to our AppInbox, which can be done using the `@stackr/cli` as follow

```bash
npx @stackr/cli@latest add hook <hook-contract-address>
```

For detailed info , you can refer to the doc [here](https://docs.stf.xyz/build/cli/add-hook)

And that's it, you have successfully created the Hook logic that will be executed every time a batch is submitted to the AppInbox contract for your MRU.

## Project structure

```bash
.
├── .gitignore
├── genesis-state.json
├── src
│   ├── index.ts ## -> starting point, everything gets imported here.
│   ├── server.ts ## -> server setup if any in the example.
│   ├── cli.ts ## -> CLI interaction setup if any in the example.
│   ├── contract ## -> hook contracts
│   │   ├── Hook.sol ## -> Hook contract to send the stateRoot of the latest block to L2Inbox via GMP
│   │   └── L2Inbox.sol ## -> Inbox on L2 to keep record of the latest state Root of the MRU
│   ├── stackr
│       ├── machine.ts ## -> preferred place to keep your State Machine(s) and export from
│       ├── mru.ts ## -> place to initialize your MicroRollup
│       ├── schemas.ts ## -> one place to create and export all schemas from
│       ├── state.ts ## -> file to define your State class, can be omitted if state is trivial.
│       └── transitions.ts ## -> one place to store all your transitions & hooks _(hooks can have seaprate hooks.ts file too.)_
└── stackr.config.ts
```

Note: Some files are specific to certain examples, as mentioned in the tree above.

## How to run?

### Run using Node.js :rocket:

```bash
npm start
```

### Run using Docker :whale:

- Build the image using the following command:

```bash
# For Linux
docker build -t rollup:latest .

# For Mac with Apple Silicon chips
docker buildx build --platform linux/amd64,linux/arm64 -t rollup:latest .
```

- Run the Docker container using the following command:

```bash
# If using SQLite as the datastore
docker run --env-file .env -v ./db.sqlite:/app/db.sqlite -p <HOST_PORT>:<CONTAINER_PORT> --name=rollup -it rollup:latest

# If using other URI based datastores
docker run --env-file .env -p <HOST_PORT>:<CONTAINER_PORT> --name=rollup -it rollup:latest
```

## Playground Plugin

To leverage examples and test the SDK, you can use Stackr's Playground hosted at: [https://playground.stackrlabs.xyz](https://playground.stackrlabs.xyz).

In you application, add Playground by importing the following:

```ts
import { Playground } from "@stackr/sdk/plugins";

const rollup = ...
await rollup.init();

Playground.init(rollup);
// this will start a server at http://localhost:42069, which is taken as input by the Playground
```

Full instructions can be found at [here](https://docs.stf.xyz/build/plugins/playground)

## Vulcan Explorer

To explore your submitted blocks and batches, you can use the Vulcan Explorer hosted at: [https://explorer.vulcan.stf.xyz/](https://explorer.vulcan.stf.xyz/).
