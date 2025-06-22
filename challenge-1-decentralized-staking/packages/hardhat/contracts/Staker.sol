// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping (address => uint256) public balances;

    bool public openForWithdraw = false;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 100 hours;
    uint256 public totalBalance = 0;

    event Stake(address, uint256);
    event Withdraw(address, uint256);

    receive() external payable {
        stake();
    }

    modifier notCompleted() {
        require(ExampleExternalContract(exampleExternalContract).completed() == false, "Contract finished!");
        _;
    }

    function stake() public payable {
        require(timeLeft() > 0, "Past deadline duh");
        require(msg.value > 0, "Send some ETH brokie!");
        balances[msg.sender] += msg.value;
        totalBalance += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {return 0;}
        else return (deadline - block.timestamp);
    }

    function withdraw() public notCompleted {
        require(openForWithdraw, "Not open for withdrawl!");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Get lost!");

        balances[msg.sender] = 0;
        totalBalance -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");

        require(success, "Oopsie, that was a fail!");

        emit Withdraw(msg.sender, amount);
    }

    function execute() public notCompleted {
        require(timeLeft() == 0, "Time not ended folks!");
        if (totalBalance >= threshold) {
            ExampleExternalContract(exampleExternalContract)
            .complete{value: totalBalance}();
            console.log("Executed successfully");
            }
        else {
            console.log("All you had to do, was to reach the damn Threshold, CJ!");
            openForWithdraw = true;}
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
