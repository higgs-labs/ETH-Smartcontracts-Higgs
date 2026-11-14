// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Escrow — the running example (starter)
/// @notice A simple crowdfunding escrow. Backers deposit ETH toward a goal.
///         The owner can withdraw only if the goal is reached.
/// @dev Complete the TODOs. We will extend and secure this over later lessons.
contract Escrow {
    // --- State ---------------------------------------------------------------

    // TODO 1: the address that deployed the contract (the beneficiary/owner).
    //         Make it public and immutable.

    // TODO 2: the funding goal in wei. Public and immutable.

    // TODO 3: a mapping from backer address => total wei they have deposited.
    //         Make it public so we get a free getter.

    // The running total pledged so far.
    uint256 public totalPledged;

    // --- Events --------------------------------------------------------------

    // TODO 4: declare an event `Pledged(address indexed backer, uint256 amount)`.

    // --- Modifiers -----------------------------------------------------------

    // TODO 5: a modifier `onlyOwner` that reverts unless msg.sender == owner.

    // --- Constructor ---------------------------------------------------------

    constructor(uint256 _goal) {
        // TODO 6: set owner to the deployer and goal to _goal.
    }

    // --- Functions -----------------------------------------------------------

    /// @notice Back the campaign with ETH.
    function pledge() external payable {
        // TODO 7: reject zero-value pledges with a custom error or require.
        // TODO 8: record the deposit, bump totalPledged, emit Pledged.
    }

    /// @notice Owner withdraws all funds, but only once the goal is reached.
    function withdraw() external {
        // TODO 9: restrict to owner (use the modifier).
        // TODO 10: require totalPledged >= goal.
        // TODO 11: send the balance to the owner.
    }
}
