// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.28;

import {Governor,IGovernor} from "lib/openzeppelin-contracts/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorSettings} from "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorTimelockControl} from "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import {GovernorVotes} from "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "lib/openzeppelin-contracts/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";

/**
 @notice GovernerDAO contract
 @author anurag shingare
 * GovernerDAO an core contract of DAO protocol that performs all the main functions for DAO protocol
 * Contract contains the function like createProposal(), castVote(), queue() and execute()
 * This are the some of the main function required for basic DAO protocol
 @dev GovernerDAO contract is one of the main and core contract for DAO mechanism.

 @notice GovernorSettings(VOTING_DELAY, VOTING_PERIOD, PROPOSAL_THRESHOLD)
 * VOTING_DELAY -> 1 block
 * VOTING_PERIOD -> 50400(1 week)
 * PROPOSAL_THRESHOLD -> 0/1/2 (depends on protocol rule)

 @dev Different voting phase/state in DAO protocol
    Pending,    //0
    Active,     //1
    Canceled,   //2
    Defeated,   //3
    Succeeded,  //4
    Queued,     //5
    Expired,    //6
    Executed    //7
 */


contract GovernerDAO is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {

    // Here we can set proposal threshold and quorum percentage!!!
    constructor(IVotes _token, TimelockController _timelock)
        Governor("GovernorDAO")
        GovernorSettings(1 /* 1 block */, 50400 /* 1 week */, 0 /*proposal threshold */)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {}

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _queueOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint48)
    {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }
}
