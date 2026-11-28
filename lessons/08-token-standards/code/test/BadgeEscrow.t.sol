// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {BadgeEscrow} from "../src/BadgeEscrow.sol";
import {BackerBadge} from "../src/BackerBadge.sol";
import {IBadgeEscrow} from "../src/IBadgeEscrow.sol";
import {CampaignToken} from "../src/CampaignToken.sol";

/// Claims to be an escrow. Says yes to every ERC-165 question, mints whatever it likes.
contract FakeEscrow {
    function supportsInterface(bytes4) external pure returns (bool) {
        return true;
    }

    function mintTo(BackerBadge badge, address to) external returns (uint256) {
        return badge.mint(to);
    }
}

contract BadgeEscrowTest is Test {
    BadgeEscrow internal escrow;
    BackerBadge internal badge;
    CampaignToken internal token;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");

    uint256 internal constant GOAL = 1_000e18;
    uint256 internal constant DEADLINE = 1_900_000_000;

    function setUp() public {
        token = new CampaignToken(1_000_000e18);
        badge = new BackerBadge();
        escrow = new BadgeEscrow(token, badge, GOAL, DEADLINE);
        badge.addEscrow(address(escrow));

        address[3] memory users = [alice, bob, carol];
        for (uint256 i; i < users.length; i++) {
            token.mint(users[i], 2_000e18);
            vm.prank(users[i]);
            token.approve(address(escrow), type(uint256).max);
        }
    }

    function test_ClaimBadge_AwardsOneBadge() public {
        vm.startPrank(alice);
        escrow.pledge(GOAL);

        uint256 id = escrow.claimBadge();
        vm.stopPrank();

        assertEq(badge.ownerOf(id), alice);
        assertEq(badge.balanceOf(alice), 1);
    }

    function test_ClaimBadge_Reverts_WhenGoalNotReached() public {
        vm.startPrank(alice);
        escrow.pledge(GOAL - 1);

        vm.expectRevert(abi.encodeWithSelector(BadgeEscrow.GoalNotYetReached.selector, alice));
        escrow.claimBadge();
        vm.stopPrank();
    }

    function test_ClaimBadge_Reverts_ForNonBacker() public {
        vm.prank(alice);
        escrow.pledge(GOAL);

        vm.prank(carol);
        vm.expectRevert(abi.encodeWithSelector(BadgeEscrow.NotABacker.selector, carol));
        escrow.claimBadge();
    }

    function test_ClaimBadge_Reverts_OnSecondClaim() public {
        vm.startPrank(alice);
        escrow.pledge(GOAL);
        escrow.claimBadge();

        vm.expectRevert(abi.encodeWithSelector(BackerBadge.AlreadyAwarded.selector, alice));
        escrow.claimBadge();
        vm.stopPrank();
    }

    /// Transferring the badge away does not let the backer claim a new one.
    function test_ClaimBadge_Reverts_AfterTransferringBadge() public {
        vm.startPrank(alice);
        escrow.pledge(GOAL);
        uint256 id = escrow.claimBadge();
        badge.transferFrom(alice, bob, id);

        vm.expectRevert(abi.encodeWithSelector(BackerBadge.AlreadyAwarded.selector, alice));
        escrow.claimBadge();
        vm.stopPrank();
    }

    function test_Badge_CannotBeMintedDirectly() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(BackerBadge.NotAnEscrow.selector, alice));
        badge.mint(alice);
    }

    function test_Badge_UnregisteredEscrowCannotMint() public {
        BadgeEscrow rogue = new BadgeEscrow(token, badge, GOAL, DEADLINE);
        vm.startPrank(alice);
        token.approve(address(rogue), type(uint256).max);
        rogue.pledge(GOAL);
        vm.expectRevert(abi.encodeWithSelector(BackerBadge.NotAnEscrow.selector, address(rogue)));
        rogue.claimBadge();
        vm.stopPrank();
    }

    /// Same backer, two campaigns, one badge contract: two distinct badges.
    function test_ClaimBadge_TwoEscrows_SameBackerGetsOneBadgeEach() public {
        BadgeEscrow escrow2 = new BadgeEscrow(token, badge, GOAL, DEADLINE);
        badge.addEscrow(address(escrow2));
        vm.startPrank(alice);
        token.approve(address(escrow2), type(uint256).max);
        escrow.pledge(GOAL);
        escrow2.pledge(GOAL);
        uint256 id1 = escrow.claimBadge();
        uint256 id2 = escrow2.claimBadge();
        vm.stopPrank();

        assertTrue(id1 != id2);
        assertEq(badge.balanceOf(alice), 2);
        assertEq(badge.campaignOf(id1), address(escrow));
        assertEq(badge.campaignOf(id2), address(escrow2));
    }

    /// A second claim on the same escrow is still refused.
    function test_ClaimBadge_TwoEscrows_SecondClaimStillReverts() public {
        BadgeEscrow escrow2 = new BadgeEscrow(token, badge, GOAL, DEADLINE);
        badge.addEscrow(address(escrow2));
        vm.startPrank(alice);
        token.approve(address(escrow2), type(uint256).max);
        escrow2.pledge(GOAL);
        escrow2.claimBadge();
        vm.expectRevert(abi.encodeWithSelector(BackerBadge.AlreadyAwarded.selector, alice));
        escrow2.claimBadge();
        vm.stopPrank();
    }

    /// Announcing the interface is not enough: the owner has not registered the fake.
    function test_Badge_FakeEscrowClaimingInterfaceCannotMint() public {
        FakeEscrow fake = new FakeEscrow();
        assertTrue(fake.supportsInterface(type(IBadgeEscrow).interfaceId));
        vm.expectRevert(abi.encodeWithSelector(BackerBadge.NotAnEscrow.selector, address(fake)));
        fake.mintTo(badge, alice);
    }

    function test_AddEscrow_Reverts_ForEOA() public {
        vm.expectRevert(abi.encodeWithSelector(BackerBadge.NotABadgeEscrow.selector, alice));
        badge.addEscrow(alice);
    }

    function test_AddEscrow_Reverts_ForContractWithoutInterface() public {
        vm.expectRevert(abi.encodeWithSelector(BackerBadge.NotABadgeEscrow.selector, address(token)));
        badge.addEscrow(address(token));
    }

    function test_BadgeEscrow_SupportsItsInterface() public view {
        assertTrue(escrow.supportsInterface(type(IBadgeEscrow).interfaceId));
        assertTrue(escrow.supportsInterface(0x01ffc9a7)); // ERC-165 itself
    }
}
