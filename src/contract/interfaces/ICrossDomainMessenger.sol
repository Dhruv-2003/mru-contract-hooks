// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface ICrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external;
}
