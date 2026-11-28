// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {VulnerableEscrow} from "../src/VulnerableEscrow.sol";
import {SafeEscrow} from "../src/SafeEscrow.sol";
import {Attacker} from "../src/Attacker.sol";

/// @title Re-entrancy: proof the attack works, and the fix stops it.
/// @dev  forge test -vvv
contract ReentrancyTest is Test {
    address internal victimA = makeAddr("victimA");
    address internal victimB = makeAddr("victimB");
    address internal hacker = makeAddr("hacker");

    /// The attack DRAINS the vulnerable escrow: attacker leaves with more than
    /// it deposited, taking honest backers' funds.
    function test_Attack_Drains_Vulnerable() public {
        VulnerableEscrow escrow = new VulnerableEscrow();

        // Two honest backers deposit 5 ETH each → 10 ETH in the pot.
        vm.deal(victimA, 5 ether);
        vm.prank(victimA);
        escrow.deposit{value: 5 ether}();
        vm.deal(victimB, 5 ether);
        vm.prank(victimB);
        escrow.deposit{value: 5 ether}();

        assertEq(address(escrow).balance, 10 ether);

        // Attacker seeds 1 ETH and re-enters.
        vm.deal(hacker, 1 ether);
        vm.startPrank(hacker);
        Attacker attacker = new Attacker(address(escrow));
        attacker.attack{value: 1 ether}();
        vm.stopPrank();

        // Escrow is drained; attacker holds far more than it put in.
        assertEq(address(escrow).balance, 0);
        assertGt(address(attacker).balance, 1 ether);
    }

    /// The SAME attack FAILS against the hardened escrow. The guard reverts,
    /// so the whole transaction reverts and no funds move.
    function test_Attack_Fails_Against_Safe() public {
        SafeEscrow escrow = new SafeEscrow();

        vm.deal(victimA, 5 ether);
        vm.prank(victimA);
        escrow.deposit{value: 5 ether}();

        vm.deal(hacker, 1 ether);
        vm.startPrank(hacker);
        Attacker attacker = new Attacker(address(escrow));
        vm.expectRevert(); // nonReentrant trips during the re-entrant call
        attacker.attack{value: 1 ether}();
        vm.stopPrank();

        // Honest funds are intact.
        assertEq(address(escrow).balance, 5 ether);
    }
}
