// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PersonalVault {
    // State Variables
    address public owner;
    uint256 public unlockTime;

    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);

    // Custom Errors
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    // Constructor
    constructor(uint256 _unlockTime) payable {
        require(
            _unlockTime > block.timestamp,
            "Unlock time must be in the future"
        );

        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    // Modifier
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    /// @notice Deposit ETH into the vault
    function deposit() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH");

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw all ETH after unlock time
    function withdraw() external onlyOwner {
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        uint256 amount = address(this).balance;
        require(amount > 0, "No balance");

        // Interaction
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(amount, block.timestamp);
    }

    /// @notice Extend lock period
    function extendLock(uint256 newTime) external onlyOwner {
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        unlockTime = newTime;

        emit LockExtended(newTime);
    }

    /// @notice Get current contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}