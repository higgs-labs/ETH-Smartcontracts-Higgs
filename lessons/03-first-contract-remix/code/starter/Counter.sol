// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Counter — your first contract (starter)
/// @notice Complete the TODOs, then compile and deploy in Remix.
contract Counter {
    // A single piece of on-chain state.
    // TODO 1: declare a public unsigned integer named `number`.
    //         Making it `public` auto-generates a getter you can call for free.


    /// @notice Increase the counter by one.
    /// This changes state, so it is a transaction and costs gas.
    function increment() external {
        // TODO 2: add one to `number`.
    }

    /// @notice Read the counter without changing state.
    /// `view` means "no writes", so this can be called for free.
    /// (Note: the public getter already does this; this is to see `view` explicitly.)
    function current() external view returns (uint256) {
        // TODO 3: return `number`.
    }
}
