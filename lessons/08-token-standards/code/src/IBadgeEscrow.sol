// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IBadgeEscrow — what BackerBadge expects from an escrow
/// @dev `type(IBadgeEscrow).interfaceId` is the ERC-165 id escrows must announce.
interface IBadgeEscrow {
    function claimBadge() external returns (uint256 id);
}
