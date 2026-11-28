// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title SafeEscrow — the same escrow, hardened
/// @notice Fixes the re-entrancy bug two independent ways:
///         1. Checks-Effects-Interactions: update state BEFORE the external call.
///         2. A `nonReentrant` guard as defense in depth.
/// @dev Either fix alone stops the attack; we show both to teach the principles.
contract SafeEscrow is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Refund the caller's balance, safely.
    function refund() external nonReentrant {
        // Checks
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to refund");

        // Effects — zero the balance BEFORE any external call
        balances[msg.sender] = 0;

        // Interactions — now it is safe to hand out ETH
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
