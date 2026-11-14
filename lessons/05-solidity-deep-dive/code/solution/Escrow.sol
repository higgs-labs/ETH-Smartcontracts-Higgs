// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// --- Errors --------------------------------------------------------------
// Custom errors are cheaper than require-strings and self-documenting.
error SendFailed(address recipient);
error GoalNotReached(uint256 amount, uint256 goal);
error NotOwner(address owner);
error ZeroPledge();
error GoalReached();
error DeadlinePassed();
error DeadlineNotPassed();

/// @title Escrow — the running example (solution)
/// @notice A simple crowdfunding escrow. Backers deposit ETH toward a goal.
///         The owner can withdraw only once the goal is reached.
/// @dev Intentionally NOT yet hardened. We attack and fix it in Lesson 7.
contract Escrow {
    // --- State ---------------------------------------------------------------

    uint256 public immutable goal;
    address public immutable owner;
    /// @notice How much each backer has pledged, in wei.
    mapping(address => uint256) public pledges;
    /// @notice Total pledged across all backers.
    uint256 public totalPledged;
    uint256 public immutable deadline;

    // --- Events --------------------------------------------------------------

    /// @notice Emitted on every successful pledge. `indexed` makes `backer`
    ///         filterable by off-chain apps (→ Lesson 9).
    event Pledged(address indexed backer, uint256 amount);

    event Refunded(address indexed donor, uint256 amount);

    /// @notice Emitted when the owner withdraws the raised funds.
    // event Withdrawn(address indexed to, uint256 amount);

    // --- Modifiers -----------------------------------------------------------

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(owner);
        _; // The rest of the other modifiers and the function call
    }

    // --- Constructor ---------------------------------------------------------

    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        owner = msg.sender;
        deadline = _deadline;
    }

    // --- Functions -----------------------------------------------------------

    /// @notice Back the campaign with ETH. `payable` lets it receive value.
    function pledge() external payable {
        require(0 < msg.value, ZeroPledge());
        require(totalPledged < goal, GoalReached());
        require(block.timestamp <= deadline, DeadlinePassed());
        pledges[msg.sender] += msg.value;
        totalPledged += msg.value;
        emit Pledged(msg.sender, msg.value);
    }

    /// @notice Owner withdraws all funds once the goal is reached.
    /// @dev NOTE: naive on purpose. Lesson 7 revisits the withdrawal pattern.
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(goal <= amount, GoalNotReached(amount, goal));
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, SendFailed(msg.sender));
    }


    function refund() external {
        uint256 amount = pledges[msg.sender];
        require(0 < amount, ZeroPledge());
        require(deadline < block.timestamp, DeadlineNotPassed());
        pledges[msg.sender] = 0;
        totalPledged -= amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, SendFailed(msg.sender));
        emit Refunded(msg.sender, amount);
    }
}
