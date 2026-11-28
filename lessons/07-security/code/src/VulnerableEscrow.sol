// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title VulnerableEscrow — a re-entrancy demo (DO NOT USE)
/// @notice A refundable escrow whose `refund` is exploitable by re-entrancy.
/// @dev The bug: it sends ETH BEFORE zeroing the backer's balance, so a
///      malicious contract can re-enter `refund` during the callback and drain
///      the whole contract. This is the canonical DAO-style bug.
contract VulnerableEscrow {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev VULNERABLE: interaction happens before the state update.
    function refund() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to refund");

        // ❌ external call BEFORE updating state → re-entrancy window
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        // ❌ too late: attacker already re-entered before this ran
        balances[msg.sender] = 0;
    }

    receive() external payable {}
}
