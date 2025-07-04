//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConvertor} from "./PriceConvertor.sol";


contract FundMe{

    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD  = 5*1e18;
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{

        require(msg.value.getConversionRate() >= MINIMUM_USD,"Did not send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

        

    

    function withdraw() public onlyOwner{
        for(uint256 funderIndex=0; funderIndex<funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }

        //reset the array
        funders = new address[](0);

        //actually withdraw the funds
        //tranfer
        //payable(msg.sender).transfer(address(this).balance);
        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess,"Transaction failed");
        //call - better choice
        (bool sendSuccess, ) = msg.sender.call{value:address(this).balance}("");
        require(sendSuccess,"Failed to send, Transfer was not succesfull!");
    }

    modifier onlyOwner(){
        require(msg.sender == i_owner, "Not allowed by Owner");
        _;
    }
}
