// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Counter — your first contract (solution)
/// @notice Minimal contract showing state, a write, and a free read.
contract Counter {
    /// @notice The counter value. `public` auto-generates a getter.
    uint256 public number;

    /// @notice Increase the counter by one. State change → transaction → gas.
    function increment() external {
        number += 1;
    }

    /// @notice Read the counter. `view` → no state change → free to call.
    function current() external view returns (uint256) {
        return number;
    }

    /// @notice Take-home: decrease by one, but never below zero.
    function decrement() external {
        require(number > 0, "Counter: already zero");
        number -= 1;
    }
}
