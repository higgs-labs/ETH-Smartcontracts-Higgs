// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title CampaignToken — an ERC-20 built on OpenZeppelin
/// @notice A reward token for our crowdfunding campaign. Standard-compliant, so
///         every wallet and exchange already knows how to handle it.
/// @dev We inherit the audited ERC-20 implementation and only add our policy:
///      a capped supply and owner-only minting.
contract CampaignToken is ERC20, Ownable {
    /// @notice Hard cap on total supply (in the token's smallest unit).
    uint256 public immutable cap;

    error CapExceeded(uint256 attempted, uint256 cap);

    constructor(uint256 cap_) ERC20("Campaign Token", "CMP") Ownable(msg.sender) {
        cap = cap_;
    }

    /// @notice Mint new tokens to `to`, owner-only, respecting the cap.
    function mint(address to, uint256 amount) external onlyOwner {
        if (cap < totalSupply() + amount) {
            revert CapExceeded(totalSupply() + amount, cap);
        }
        _mint(to, amount);
    }
}
