// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {IAppInbox} from "./IAppInbox.sol";

interface IBaseHook {
    function postSubmit(
        IAppInbox.Batch calldata _batch,
        address _submitter
    ) external;
}
