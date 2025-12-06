// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline;
    bool public openForWithdraw = false;
    bool public exampleExternalContractCompleted = false;

    modifier notCompleted() {
        require(!exampleExternalContractCompleted, "Staking already completed");
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);

        deadline = block.timestamp + 72 hours;
    }

    mapping(address => uint256) public balances;

    event Stake(address indexed sender, uint256 amount);

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function stake() public payable notCompleted {
        require(timeLeft() > 0, "Deadline has passed!");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public notCompleted {
        require(block.timestamp >= deadline, "Deadline not reached yet");
        require(!exampleExternalContractCompleted, "Already executed");

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{ value: address(this).balance }();
            exampleExternalContractCompleted = true;
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public notCompleted {
        require(openForWithdraw, "You can't withdraw!");

        uint256 amount = balances[msg.sender];

        require(amount > 0, "You don't have ETH in it!");

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{ value: amount }("");
        require(success, "Transfer failed");
    }

    receive() external payable {
        stake();
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
