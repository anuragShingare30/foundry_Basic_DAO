// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {Box} from "src/Box.sol";
import {GovernerDAO} from "src/GovernerDAO.sol";
import {GovToken} from "src/GovToken.sol";
import {TimeLock} from "src/TimeLock.sol";


contract GovernorDAOTest is Test{
    Box box;
    GovernerDAO governer;
    GovToken token;
    TimeLock timelock;

    uint256 minDelay = 3600; // 1-hour
    uint256 VOTING_DELAY = 1; // after delay the voting is active
    uint256 VOTING_PERIOD = 50400; // time upto which voting will continue

    address public VOTER = makeAddr("VOTER");
    address[] proposers;
    address[] executors;
    address[] targets;
    uint256[] values;
    bytes[] callData;

    function setUp() public {
        token = new GovToken();
        token.mint(VOTER, 100e18);

        vm.startPrank(VOTER);
        timelock = new TimeLock(minDelay,proposers,executors);
        governer = new GovernerDAO(token,timelock);

        bytes32 proposer_role = timelock.PROPOSER_ROLE();
        bytes32 executor_role = timelock.EXECUTOR_ROLE();

        timelock.grantRole(proposer_role, address(governer));
        timelock.grantRole(executor_role, address(0));
        vm.stopPrank();


        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function test_RevertsIf_CallerIsNotOwnerToChangeNum() public {
        vm.expectRevert();
        box.changeNum(10);
    }

    function test_CheckGovernerDAO() public{
        // 1. propose to DAO
        uint256 replaceNum = 6969;
        bytes memory functionData = abi.encodeWithSignature("changeNum(uint256)", replaceNum);
        string memory description = "I want to change the number";
        targets.push(address(box));
        values.push(0);
        callData.push(functionData);
        uint256 proposalId = governer.propose(targets, values, callData, description);

        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // pending

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // active

        // 2. cast the vote
        // 0 = Against, 1 = For, 2 = Abstain for this example
        string memory reason = "I like 69 number";
        uint8 support = 1;
        vm.prank(VOTER);
        governer.castVoteWithReason(proposalId, support, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // Defeated

        // 3. queuing a proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        // governer.queue(targets, values, callData, descriptionHash);

        vm.roll(block.number + minDelay + 1);
        vm.warp(block.timestamp + minDelay + 1);

        // 4. execute the function
        governer.execute(targets, values, callData, descriptionHash);

        assert(box.getNum() == replaceNum);
    }
}