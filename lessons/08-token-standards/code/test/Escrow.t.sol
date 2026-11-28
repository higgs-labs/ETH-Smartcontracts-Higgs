// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Escrow} from "../src/Escrow.sol";
import {CampaignToken} from "../src/CampaignToken.sol";

/// @title Escrow tests (ERC-20 version)
/// @dev Run with:  forge test -vvv
contract EscrowTest is Test {
    Escrow internal escrow;
    CampaignToken internal token;

    address internal beneficiary = makeAddr("beneficiary");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    uint256 internal constant GOAL = 10_000e18;
    uint256 internal constant DEADLINE = 1_900_000_000;

    function setUp() public {
        // This test contract owns the token, so it can mint.
        token = new CampaignToken(1_000_000e18);
        vm.prank(beneficiary);
        escrow = new Escrow(token, GOAL, DEADLINE);

        // Instead of vm.deal: mint tokens to the backers...
        token.mint(alice, 1_000e18);
        token.mint(bob, 1_000e18);
        // ...and let each of them approve the escrow (the new step).
        vm.prank(alice);
        token.approve(address(escrow), type(uint256).max);
        vm.prank(bob);
        token.approve(address(escrow), type(uint256).max);
    }

    // --- Happy path ----------------------------------------------------------

    function test_Pledge_RecordsDeposit() public {
        vm.prank(alice);
        escrow.pledge(100e18);

        assertEq(escrow.pledges(alice), 100e18);
        assertEq(escrow.totalPledged(), 100e18);
        assertEq(token.balanceOf(address(escrow)), 100e18);
        assertEq(token.balanceOf(alice), 900e18);
    }

    function test_Pledge_SumsDeposit() public {
        vm.startPrank(alice);
        escrow.pledge(200e18);
        escrow.pledge(300e18);
        vm.stopPrank();

        assertEq(escrow.pledges(alice), 500e18);
        assertEq(escrow.totalPledged(), 500e18);
        assertEq(token.balanceOf(address(escrow)), 500e18);
        assertEq(token.balanceOf(alice), 500e18);
    }

    function test_Pledge_TwoDeposit() public {
        vm.prank(alice);
        escrow.pledge(200e18);
        vm.prank(bob);
        escrow.pledge(300e18);

        assertEq(escrow.pledges(alice), 200e18);
        assertEq(token.balanceOf(alice), 800e18);
        assertEq(escrow.pledges(bob), 300e18);
        assertEq(token.balanceOf(bob), 700e18);
        assertEq(escrow.totalPledged(), 500e18);
        assertEq(token.balanceOf(address(escrow)), 500e18);
    }

    function test_Pledge_EmitsEvent() public {
        vm.expectEmit(true, false, false, true, address(escrow));
        emit Escrow.Pledged(alice, 100e18);

        vm.prank(alice);
        escrow.pledge(100e18);
    }

    function test_SendToBeneficiary_TransfersToOwner_WhenGoalReached() public {
        token.mint(alice, 9_000e18);
        vm.prank(alice);
        escrow.pledge(6_000e18);
        vm.prank(bob);
        escrow.pledge(1_000e18);
        vm.prank(alice);
        escrow.pledge(3_000e18);

        vm.prank(beneficiary);
        escrow.sendToBeneficiary();

        assertEq(token.balanceOf(beneficiary), GOAL);
        assertEq(token.balanceOf(address(escrow)), 0);
    }

    function test_Refund_WhenDeadlinePassed() public {
        vm.prank(alice);
        escrow.pledge(200e18);

        vm.warp(DEADLINE + 1);
        vm.prank(alice);
        escrow.refund();

        assertEq(escrow.pledges(alice), 0);
        assertEq(escrow.totalPledged(), 0);
        assertEq(token.balanceOf(address(escrow)), 0);
        assertEq(token.balanceOf(alice), 1_000e18);
    }

    function test_Refund_OneOnly() public {
        vm.prank(alice);
        escrow.pledge(200e18);
        vm.prank(bob);
        escrow.pledge(300e18);

        vm.warp(DEADLINE + 1);
        vm.prank(alice);
        escrow.refund();

        assertEq(escrow.pledges(alice), 0);
        assertEq(escrow.pledges(bob), 300e18);
        assertEq(escrow.totalPledged(), 300e18);
        assertEq(token.balanceOf(address(escrow)), 300e18);
        assertEq(token.balanceOf(alice), 1_000e18);
        assertEq(token.balanceOf(bob), 700e18);
    }

    // --- Reverts -------------------------------------------------------------

    function test_Pledge_Reverts_OnZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Escrow.ZeroPledge.selector, alice));
        escrow.pledge(0);
    }

    /// New in the ERC-20 version: no approval, no pledge.
    function test_Pledge_Reverts_WithoutAllowance() public {
        address carol = makeAddr("carol");
        token.mint(carol, 100e18);

        vm.prank(carol);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(escrow), 0, 100e18)
        );
        escrow.pledge(100e18);
    }

    function test_Pledge_Reverts_WhenBalanceTooLow() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 1_000e18, 1_001e18)
        );
        escrow.pledge(1_001e18);
    }

    function test_SendToBeneficiary_Reverts_WhenGoalNotReached() public {
        vm.prank(alice);
        escrow.pledge(100e18);

        vm.prank(beneficiary);
        vm.expectRevert(abi.encodeWithSelector(Escrow.GoalNotReached.selector, 100e18, GOAL));
        escrow.sendToBeneficiary();
    }

    function test_Refund_Reverts_WhenGoalReached() public {
        token.mint(alice, 9_000e18);
        vm.prank(alice);
        escrow.pledge(GOAL);

        vm.warp(DEADLINE + 1);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Escrow.GoalReached.selector, alice));
        escrow.refund();
    }

    // --- Fuzzing -------------------------------------------------------------

    function testFuzz_Pledge_AccumulatesTotal(uint96 amount) public {
        amount = uint96(bound(amount, 1, 1_000e18));

        vm.prank(alice);
        escrow.pledge(amount);

        assertEq(escrow.totalPledged(), amount);
        assertEq(escrow.pledges(alice), amount);
    }
}
