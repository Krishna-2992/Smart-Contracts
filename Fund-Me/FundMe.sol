//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol"; 

contract FundMe{
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 1 * 1e18;
    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    constructor(){
        i_owner = msg.sender;
    }
    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't sent enough");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }
    function withdraw() public onlyOwner{
        for(uint256 funderIndex=0; funderIndex < funders.length; funderIndex++)
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders=new address[] (0);
        (bool callSuccess,) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess, "call failed");
    }
    modifier onlyOwner{
        require(msg.sender==i_owner, "sender is not owner");
        _;
    }
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }
}
