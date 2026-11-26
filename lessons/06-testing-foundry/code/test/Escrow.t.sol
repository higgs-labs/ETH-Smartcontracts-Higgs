// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {Escrow, SendFailed} from "../src/Escrow.sol";
// import {ReentrancyAttacker} from "../src/ReentrancyAttacker.sol";

contract ReentrancyAttacker {
    receive() external payable {
        if (msg.value <= msg.sender.balance) {
            // (bool ok, ) = msg.sender.call(abi.encodeCall(Escrow(msg.sender).refund, ()));
            (bool ok,) = msg.sender.call(abi.encodeWithSelector(Escrow.refund.selector));
        }
    }
}

/// @title Escrow tests
/// @notice Demonstrates forge test basics and the core vm cheatcodes.
/// @dev Run with:  forge test -vvv        (add --gas-report for gas)
contract EscrowTest is Test {
    Escrow internal escrow;

    // Named test actors. `makeAddr` gives a deterministic labelled address.
    address internal beneficiary = makeAddr("beneficiary");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    uint256 internal constant GOAL = 10 ether;
    uint256 internal constant DEADLINE = 1_900_000_000;

    /// @notice Runs before every test. Fresh contract each time → isolation.
    function setUp() public {
        // Deploy as `beneficiary` so msg.sender in the constructor is `beneficiary`.
        vm.prank(beneficiary);
        escrow = new Escrow(GOAL, DEADLINE);
    }

    // --- Happy path ----------------------------------------------------------

    function test_Pledge_RecordsDeposit() public {
        vm.deal(alice, 1 ether); // give alice some ETH
        vm.prank(alice);
        escrow.pledge{value: 1 ether}();

        assertEq(escrow.pledges(alice), 1 ether);
        assertEq(escrow.totalPledged(), 1 ether);
        assertEq(address(escrow).balance, 1 ether);
        assertEq(address(alice).balance, 0 ether);
    }

    function test_Pledge_SumsDeposit() public {
        vm.deal(alice, 0.8 ether); // give alice some ETH
        vm.prank(alice);
        escrow.pledge{value: 0.2 ether}();
        vm.prank(alice);
        escrow.pledge{value: 0.3 ether}();

        assertEq(escrow.pledges(alice), 0.5 ether);
        assertEq(escrow.totalPledged(), 0.5 ether);
        assertEq(address(escrow).balance, 0.5 ether);
        assertEq(address(alice).balance, 0.3 ether);
    }

    function test_Pledge_TwoDeposit() public {
        vm.deal(alice, 0.8 ether); // give alice some ETH
        vm.prank(alice);
        escrow.pledge{value: 0.2 ether}();
        vm.deal(bob, 0.7 ether); // give bob some ETH
        vm.prank(bob);
        escrow.pledge{value: 0.3 ether}();

        assertEq(escrow.pledges(alice), 0.2 ether);
        assertEq(address(alice).balance, 0.6 ether);
        assertEq(escrow.pledges(bob), 0.3 ether);
        assertEq(address(bob).balance, 0.4 ether);
        assertEq(escrow.totalPledged(), 0.5 ether);
        assertEq(address(escrow).balance, 0.5 ether);
    }

    function test_Pledge_EmitsEvent() public {
        vm.deal(alice, 1 ether);

        // Expect the exact event on the next call.
        vm.expectEmit(true, false, false, true, address(escrow));
        emit Escrow.Pledged(alice, 1 ether);

        vm.prank(alice);
        escrow.pledge{value: 1 ether}();
    }

    function test_SendToBeneficiary_TransfersToOwner_WhenGoalReached() public {
        // Fund the goal from two backers.
        vm.deal(alice, 6 ether);
        vm.prank(alice);
        escrow.pledge{value: 6 ether}();
        vm.deal(bob, 4 ether);
        vm.prank(bob);
        escrow.pledge{value: 4 ether}();

        uint256 before = beneficiary.balance;
        vm.prank(beneficiary);
        escrow.sendToBeneficiary();

        assertEq(beneficiary.balance, before + GOAL);
        assertEq(address(escrow).balance, 0);
    }

    function test_Refund_WhenDeadlinePassed() public {
        vm.deal(alice, 0.8 ether); // give alice some ETH
        vm.prank(alice);
        escrow.pledge{value: 0.2 ether}();

        vm.warp(DEADLINE + 1);
        vm.prank(alice);
        escrow.refund();

        assertEq(escrow.pledges(alice), 0 ether);
        assertEq(escrow.totalPledged(), 0 ether);
        assertEq(address(escrow).balance, 0 ether);
        assertEq(address(alice).balance, 0.8 ether);
    }

    function test_Refund_OneOnly() public {
        vm.deal(alice, 0.8 ether); // give alice some ETH
        vm.prank(alice);
        escrow.pledge{value: 0.2 ether}();
        vm.deal(bob, 0.7 ether); // give bob some ETH
        vm.prank(bob);
        escrow.pledge{value: 0.3 ether}();

        vm.warp(DEADLINE + 1);
        vm.prank(alice);
        escrow.refund();

        assertEq(escrow.pledges(alice), 0 ether);
        assertEq(escrow.pledges(bob), 0.3 ether);
        assertEq(escrow.totalPledged(), 0.3 ether);
        assertEq(address(escrow).balance, 0.3 ether);
        assertEq(address(alice).balance, 0.8 ether);
        assertEq(address(bob).balance, 0.4 ether);
    }

    // // --- Reverts (the important half) ----------------------------------------

    function test_Pledge_Reverts_OnZeroValue() public {
        vm.prank(alice);
        // vm.expectRevert(abi.encodeWithSelector(Escrow.ZeroPledge.selector, alice));
        vm.expectRevert(abi.encodeWithSelector(Escrow.ZeroPledge.selector, alice));
        escrow.pledge{value: 0}();
    }

    function test_SendToBeneficiary_Reverts_WhenGoalNotReached() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        escrow.pledge{value: 1 ether}();

        vm.prank(beneficiary);
        // Custom error carries data — match it precisely.
        vm.expectRevert(abi.encodeWithSelector(Escrow.GoalNotReached.selector, 1 ether, GOAL));
        escrow.sendToBeneficiary();
    }

    function test_Refund_Fails_WhenReject() public {
        vm.deal(alice, 0.8 ether); // give alice some ETH
        vm.prank(alice);
        escrow.pledge{value: 0.2 ether}();
        vm.warp(DEADLINE + 1);

        vm.mockCallRevert(alice, abi.encode(), "fakeReject");
        vm.expectRevert(abi.encodeWithSelector(SendFailed.selector, alice));
        vm.prank(alice);
        escrow.refund();

        assertEq(escrow.pledges(alice), 0.2 ether);
        assertEq(escrow.totalPledged(), 0.2 ether);
        assertEq(address(escrow).balance, 0.2 ether);
        assertEq(address(alice).balance, 0.6 ether);
    }

    // // --- Resistant to reentrancy ---------------------------------------------

    function test_Resists_OnReentrancy() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker();
        vm.deal(address(attacker), 0.2 ether); // give attacker some ETH
        vm.prank(address(attacker));
        escrow.pledge{value: 0.2 ether}();
        vm.deal(bob, 0.7 ether); // give bob some ETH
        vm.prank(bob);
        escrow.pledge{value: 0.3 ether}();

        vm.warp(DEADLINE + 1);
        vm.prank(address(attacker));
        // attacker.callRefund(escrow);
        escrow.refund();

        assertEq(address(escrow).balance, 0.3 ether);
        assertEq(address(attacker).balance, 0.2 ether);
    }

    // // --- Fuzzing (stretch) ---------------------------------------------------

    /// @notice `amount` is randomised by the fuzzer across many runs.
    function testFuzz_Pledge_AccumulatesTotal(uint96 amount) public {
        vm.assume(0 < amount);
        vm.deal(alice, amount);

        vm.prank(alice);
        escrow.pledge{value: amount}();

        assertEq(escrow.totalPledged(), amount);
        assertEq(escrow.pledges(alice), amount);
    }
}
