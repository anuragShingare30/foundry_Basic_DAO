// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 @notice Simple Box contract
 @author anurag shingare
 * We will create an sample basic proposal to change the number
 * Contract contains simple changeNum and getNum function

 @notice This is a sample contract just to show how DAO protocol works.
 * We can implement whatever changes we are considering in proposal.
 */


contract Box is Ownable{
    uint256 public num;

    event NumChanged(uint256 _num);

    constructor() Ownable(msg.sender) {}

    function changeNum(uint256 _num) external onlyOwner{
        num = _num;
        emit NumChanged(num);
    }

    function getNum() public view returns(uint256){
        return num;
    }
}