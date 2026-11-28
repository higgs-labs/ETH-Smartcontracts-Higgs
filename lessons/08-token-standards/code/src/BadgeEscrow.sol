// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Escrow} from "./Escrow.sol";
import {IBadgeEscrow} from "./IBadgeEscrow.sol";
import {BackerBadge} from "./BackerBadge.sol";

/// @title BadgeEscrow — Escrow that awards one BackerBadge per successful backer
/// @dev The badge owner must register this escrow first (`badge.addEscrow(escrow)`).
///      The badge also checks, through ERC-165, that the escrow announces `IBadgeEscrow`.
///      Several escrows can share one badge contract.
contract BadgeEscrow is Escrow, ERC165, IBadgeEscrow {
    BackerBadge public immutable badge;

    error NotABacker(address sender);
    error GoalNotYetReached(address sender);

    constructor(IERC20 _token, BackerBadge _badge, uint256 _goal, uint256 _deadline)
        Escrow(_token, _goal, _deadline)
    {
        badge = _badge;
    }

    /// @notice Once the goal is reached, each backer can claim their badge, once.
    function claimBadge() external override returns (uint256 id) {
        require(0 < pledges[msg.sender], NotABacker(msg.sender));
        require(goal <= totalPledged, GoalNotYetReached(msg.sender));
        id = badge.mint(msg.sender); // reverts with AlreadyAwarded on a second claim
    }

    /// @notice ERC-165: announce that we implement `IBadgeEscrow`.
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IBadgeEscrow).interfaceId || super.supportsInterface(interfaceId);
    }
}
