pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256  amountOfTokens, uint256 amountOfETH);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function valueCalc(uint256 _amount) internal returns (uint256) {
        return (_amount / tokensPerEth);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH brokie");
        uint256 tokens = msg.value * tokensPerEth;
        require(yourToken.balanceOf(address(this)) >= tokens, "Vendor is poor");
        
        yourToken.transfer(msg.sender, tokens); 
        emit BuyTokens(msg.sender, msg.value, tokens);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool sent, ) = owner().call{value: balance}("");
        return sent;
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public returns (bool) {
        yourToken.transferFrom(msg.sender, address(this), _amount);
        (bool sent, ) = owner().call{value: valueCalc(_amount)}("");
        emit SellTokens(msg.sender, _amount, valueCalc(_amount));

        return sent;
    }
}
