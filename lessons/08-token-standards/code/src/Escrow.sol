// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Escrow — Lesson 8 final version (ERC-20 pledges)
/// @notice Crowdfunding escrow priced in a stable ERC-20 token instead of volatile ETH.
/// @dev Backers must `approve` the escrow first; `pledge` then pulls the tokens with `transferFrom`.
contract Escrow {
    using SafeERC20 for IERC20;

    // --- State ---------------------------------------------------------------

    /// @notice The ERC-20 token used for pledges (a stable token in production).
    IERC20 public immutable token;
    /// @notice Goal, in the token's smallest unit.
    uint256 public immutable goal;
    uint256 public immutable deadline;
    address public beneficiary;
    /// @notice How much each backer has pledged, in token units.
    mapping(address => uint256) public pledges;
    /// @notice Total pledged across all backers.
    uint256 public totalPledged;

    // --- Errors --------------------------------------------------------------

    error NotBeneficiary(address beneficiary, address sender);
    error GoalNotReached(uint256 amount, uint256 goal);
    error ZeroPledge(address sender);
    error GoalReached(address sender);
    error DeadlinePassed(address sender);
    error DeadlineNotPassed(address sender);

    // --- Events --------------------------------------------------------------

    event Pledged(address indexed backer, uint256 amount);
    event Refunded(address indexed donor, uint256 amount);

    // --- Constructor ---------------------------------------------------------

    constructor(IERC20 _token, uint256 _goal, uint256 _deadline) {
        token = _token;
        goal = _goal;
        beneficiary = msg.sender;
        deadline = _deadline;
    }

    // --- Functions -----------------------------------------------------------

    /// @notice Send all the tokens held to the beneficiary once the goal is reached.
    function sendToBeneficiary() public {
        uint256 amount = token.balanceOf(address(this));
        require(goal <= amount, GoalNotReached(amount, goal));
        token.safeTransfer(beneficiary, amount);
    }

    /// @notice Back the campaign with `amount` tokens. The caller must have approved the escrow for at least `amount`.
    function pledge(uint256 amount) external {
        require(0 < amount, ZeroPledge(msg.sender));
        require(totalPledged < goal, GoalReached(msg.sender));
        require(block.timestamp <= deadline, DeadlinePassed(msg.sender));
        pledges[msg.sender] += amount;
        totalPledged += amount;
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Pledged(msg.sender, amount);
    }

    /// @notice Get the pledge back after the deadline, if the goal was missed.
    function refund() external {
        uint256 amount = pledges[msg.sender];
        require(0 < amount, ZeroPledge(msg.sender));
        require(deadline < block.timestamp, DeadlineNotPassed(msg.sender));
        require(totalPledged < goal, GoalReached(msg.sender));
        pledges[msg.sender] = 0;
        totalPledged -= amount;
        token.safeTransfer(msg.sender, amount);
        emit Refunded(msg.sender, amount);
    }
}
