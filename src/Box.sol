// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

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