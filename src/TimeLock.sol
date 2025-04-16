// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {TimelockController} from "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";

/**
 @notice TimeLock contract
 @author anurag shingare
 * TimelockController inherited contract
 */

contract TimeLock is TimelockController {
    constructor(
        uint256 minDelay, 
        address[] memory proposers, 
        address[] memory executors
    ) TimelockController(minDelay,proposers,executors,msg.sender) {}
}