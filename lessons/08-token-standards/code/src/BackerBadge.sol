// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IBadgeEscrow} from "./IBadgeEscrow.sol";

/// @title BackerBadge — an ERC-721 (NFT) awarded to campaign backers
/// @notice Same standards idea as ERC-20, but each token is unique (a distinct id + owner).
/// @dev One badge contract can serve any number of escrows. The owner registers each escrow,
///      and the token id is hash(escrow, backer): one badge per backer per campaign, even after
///      the badge has been transferred.
contract BackerBadge is ERC721, Ownable {
    error AlreadyAwarded(address backer);
    error NotAnEscrow(address caller);
    error NotABadgeEscrow(address account);

    mapping(address escrow => bool) public isEscrow;
    mapping(uint256 id => address escrow) public campaignOf;

    constructor() ERC721("Backer Badge", "BADGE") Ownable(msg.sender) {}

    /// @notice Allow `escrow` to mint badges. Owner-only, and `escrow` must announce `IBadgeEscrow` (ERC-165).
    /// @dev The ERC-165 check catches mistakes (an EOA, the wrong contract). It is not security:
    ///      any contract can claim an interface. The allowlist is what keeps strangers out.
    function addEscrow(address escrow) external onlyOwner {
        isEscrow[escrow] = true;
        require(ERC165Checker.supportsInterface(escrow, type(IBadgeEscrow).interfaceId), NotABadgeEscrow(escrow));
    }

    /// @notice Award the badge to `to`. Registered escrows only: `msg.sender` is the campaign.
    function mint(address to) external returns (uint256 id) {
        require(isEscrow[msg.sender], NotAnEscrow(msg.sender));
        id = uint256(keccak256(abi.encode(msg.sender, to)));
        require(_ownerOf(id) == address(0), AlreadyAwarded(to));
        campaignOf[id] = msg.sender;
        _mint(to, id);
    }
}
