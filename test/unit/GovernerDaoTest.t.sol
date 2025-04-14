// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {Box} from "src/Box.sol";
import {GovernerDAO} from "src/GovernerDAO.sol";
import {GovToken} from "src/GovToken.sol";
import {TimeLock} from "src/TimeLock.sol";


/**
 @notice GovernorDAOTest test contract
 * Here we will follow the basic DAO protocol mechanism:
    1. Creating Proposal -> Any token holder(delegated) can create proposal
    2. Casting Vote -> After the delay, the proposal becomes Active. Vote started
    3. queuing a proposal -> If a timelock was set up, the first step to execution is queueing
    4. Executing -> Once Enough votes and quorum was reached, protocol will execute the function automatically
 
 * We will follow the voting state to perform the specific action based on state:
    1. Pending(0)
        - Proposal just created.
        - No voting allowed yet
        - It stays here until the voting delay has passed (e.g., 1 block, 1 day).
    2. Active(1):
        - After the delay, the proposal becomes Active
        - Voting starts
        - Token holders(call delegatedlly)
    3. Defeated(3):
        - Voting ends.
        - Not enough support or didn’t meet quorum.
        - Proposal is rejected and cannot proceed
    4. Succeeded(4):
        - Voting ended successfully
        - Enough votes and quorum was reached.
    5. Queued(5):
        - This introduces a delay before execution(Ex. 2 days) for safety
        - The timelock helps prevent instant execution of critical changes.
    6. Executed(7):
        - After the TimeLock delay passes, you can now call execute() to run the proposal
        - The calldata in the proposal is used to call the target contract function (e.g., upgrade logic, transfer funds, update parameter).
 
 * Conditions for Proposal to Succeed:
    1. Quorum is reached (a minimum number of votes(in %) has vote for proposal).
    2. More “For” votes than “Against”.
 
 * If quorum isn’t reached or more votes are “Against”, it goes to Defeated.

 * Some important points to remember in DAO based protocol
    1. Once a proposal is active, delegates can cast their vote. Note that it is delegates who carry voting power!!!
    2. Proposal to be succeded -> Quorum should be reached and enough "for" votes should be there
    3. If a timelock was set up, the first step before execution is queueing!!!
    4. Any token holder (or only certain ones, depending on rules) can create a proposal.
    5. We will use 'function signature' of desired function to be executed in our 'calldata' parameter
    6. The actions will be correcetly executed -> By following correct state!!! 

 */


contract GovernorDAOTest is Test{
    Box box;
    GovernerDAO governer;
    GovToken token;
    TimeLock timelock;

    uint256 minDelay = 3600; // 1-hour
    uint256 VOTING_DELAY = 1; // time upto which proposal will be in pending state
    uint256 VOTING_PERIOD = 50400; // time upto which voting will continue
    uint256 QUORUM = 4; // minimum number of voter voted for proposal(in %)

    address public VOTER = makeAddr("VOTER");
    address public NONHOLDER_VOTER = makeAddr("NONHOLDER_VOTER");
    address public PROPOSER = makeAddr("PROPOSER");

    address[] proposers;
    address[] executors;
    address[] targets;
    uint256[] values;
    bytes[] callData;

    function setUp() public {
        token = new GovToken();
        token.mint(VOTER, 100e18);

        vm.startPrank(VOTER);
        token.delegate(VOTER); // Point of error
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

    address[] _targetsT;
    uint256[] _valuesT;
    bytes[] _callDataT;
    function test_RevertsIf_NonTokenHolderVotes() public {
        string memory description = "Change the number";
        uint256 changedNum = 999;
        bytes memory functionData = abi.encodeWithSignature("changeNum(uint256)", changedNum);
        _targetsT.push(address(box));
        _valuesT.push(0);
        _callDataT.push(functionData);
        uint256 proposalId = governer.propose(_targetsT, _valuesT, _callDataT, description);

        // Pending state -> Active state -> Voting Starts!!!
        vm.roll(block.number + VOTING_DELAY + 1);
        vm.warp(block.timestamp + VOTING_DELAY + 1);

        uint8 vote = 1;
        string memory reason = "I like the number 999";
        vm.startPrank(NONHOLDER_VOTER);
        // vm.expectRevert();
        governer.castVoteWithReason(proposalId, vote, reason);
        vm.stopPrank();
    }

    ///////////////////
    // Proposal State //
    ///////////////////
    address[] _targets;
    uint256[] _values;
    bytes[] _callData;
    function test_checkProposalState() public{
        // 1. create an Proposal for DAO -> Token holder(or any particular address) can create

        string memory description = "Change the number";
        uint256 changedNum = 999;
        bytes memory functionData = abi.encodeWithSignature("changeNum(uint256)", changedNum);
        _targets.push(address(box));
        _values.push(0);
        _callData.push(functionData);
        uint256 proposalId = governer.propose(_targets, _values, _callData, description);

        // Pending
        console.log("Proposal state after creating proposal:", 
            uint256(governer.state(proposalId))
        ); 

        vm.roll(block.number + VOTING_DELAY + 1);
        vm.warp(block.timestamp + VOTING_DELAY + 1);

        // Active
        console.log("Proposal state after voting delay is passed:", 
            uint256(governer.state(proposalId))
        );

        assert(uint256(governer.state(proposalId)) == 1);
    }

    ///////////////////
    // Vote casting State //
    ///////////////////
    address[] _targetsV;
    uint256[] _valuesV;
    bytes[] _callDataV;
    function test_checkVotingState() public{
        string memory description = "Change the number";
        uint256 changedNum = 999;
        bytes memory functionData = abi.encodeWithSignature("changeNum(uint256)", changedNum);
        _targetsV.push(address(box));
        _valuesV.push(0);
        _callDataV.push(functionData);
        uint256 proposalId = governer.propose(_targetsV, _valuesV, _callDataV, description);

        // Pending state -> Active state -> Voting Starts!!!
        vm.roll(block.number + VOTING_DELAY + 1);
        vm.warp(block.timestamp + VOTING_DELAY + 1);

        uint8 vote = 1;
        string memory reason = "I like the number 999";
        vm.prank(VOTER);
        governer.castVoteWithReason(proposalId, vote, reason);

        // Active -> Succeeded
        vm.roll(block.number + VOTING_PERIOD + 1);
        vm.warp(block.timestamp + VOTING_PERIOD + 1);

        assert(uint256(governer.state(proposalId)) == 4);
    }

    ///////////////////
    // Queued State //
    ///////////////////
    address[] _targetsQ;
    uint256[] _valuesQ;
    bytes[] _callDataQ;
    function test_checkQueuingState() public{
        string memory description = "Change the number";
        uint256 changedNum = 999;
        bytes memory functionData = abi.encodeWithSignature("changeNum(uint256)", changedNum);
        _targetsQ.push(address(box));
        _valuesQ.push(0);
        _callDataQ.push(functionData);
        uint256 proposalId = governer.propose(_targetsQ, _valuesQ, _callDataQ, description);

        // Pending state -> Active state -> Voting Starts!!!
        vm.roll(block.number + VOTING_DELAY + 1);
        vm.warp(block.timestamp + VOTING_DELAY + 1);

        uint8 vote = 1;
        string memory reason = "I like the number 999";
        vm.prank(VOTER);
        governer.castVoteWithReason(proposalId, vote, reason);

        // Active -> Succeeded
        vm.roll(block.number + VOTING_PERIOD + 1);
        vm.warp(block.timestamp + VOTING_PERIOD + 1);

        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governer.queue(_targetsQ, _valuesQ, _callDataQ, descriptionHash);

        // Succeeded -> Queuing
        vm.roll(block.number + minDelay + 1);
        vm.warp(block.timestamp + minDelay + 1);

        assert(uint256(governer.state(proposalId)) == 5);
    }

    ///////////////////
    // Execution State //
    ///////////////////
    // This functions covers complete working flow of DAO contract
    
    function test_checkDAOContract() public{
        // 1. propose to DAO -> Create a proposal
        uint256 replaceNum = 6969;
        bytes memory functionData = abi.encodeWithSignature("changeNum(uint256)", replaceNum);
        string memory description = "I want to change the number";
        targets.push(address(box));
        values.push(0);
        callData.push(functionData);

        vm.prank(PROPOSER);
        uint256 proposalId = governer.propose(targets, values, callData, description);

        // get the proposer address -> Not the VOTER
        console.log("Proposer address:", governer.proposalProposer(proposalId));


        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // pending

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // active

        // 2. cast the vote -> Once the proposal is active
        // 0 = Against, 1 = For, 2 = Abstain
        string memory reason = "I like 69 number";
        uint8 support = 1;
        vm.prank(VOTER);
        governer.castVoteWithReason(proposalId, support, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        // If quorum isn’t reached or more votes are “Against”, it goes to Defeated.
        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // Succeeded


        // 3. queuing a proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governer.queue(targets, values, callData, descriptionHash);

        vm.roll(block.number + minDelay + 1);
        vm.warp(block.timestamp + minDelay + 1);

        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // Queued

        // 4. execute the function
        governer.execute(targets, values, callData, descriptionHash);

        console.log("Current state of proposal:", uint256(governer.state(proposalId))); // Executed

        assert(box.getNum() == replaceNum);
        console.log("The Change number is:", box.getNum());
    }


    function test_getterFunctions() public{
        console.log(governer.proposalThreshold());
    }
}