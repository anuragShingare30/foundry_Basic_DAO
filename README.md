# Decentralized Autonomous Organizations(DAO)

**DAO -> Decentralized Organization -> `Decision are taken by community(members)` -> Proposal will be created and decision will be taken!!!**

- **A DAO is a collectively-owned organization that runs without a central entity**
- Instead of `one person/group making all the decisions, the community (members) vote for created proposal`
- The Execution will be `managed by smart contracts` on a blockchain like Ethereum.


1. **Decentralized**:
   - No central authority

2. **Autonomous**: 
    - It runs automatically using smart contracts (self-executing code).

3. **Organization**:
    - Members work for protocol/application based on there interest


# Work Flow of Basic DAO protocol

- Here we will check the basic workflow of DAO protocol:


1. **Create Governance Token**:
    - This token represents voting power. 
    - Whoever holds it can vote on proposal in the DAO.(`Depends on rules`)

2. **Basic DAO contract(Core contract)**:
    - DAO contract is the core contract of protocol that covers all the important functions for DAO
    - `propose()` -> Eligible proposers can create the proposal
    - `castVote()` -> Voters can cast the vote for particular proposal(proposal-ID).
    - `queue()` -> After voting ends, this create an delay for succesful proposal before execution!!!
    - `execution()` -> For successful proposal, protocol will automatically executes the action for specific function


3. **Proposal Submission**:
   - `propose()` -> Takes target address, values, functionSignature and description
   - Any token holder (or only certain ones, depending on rules) can create a proposal. 

4. **Voting Phase**:
    - Once a proposal is live, all eligible token holders can vote on it.
    - Voting may stay open for `VOTING_PERIOD`

5. **Quorum & Approval Check**:
    - After the voting period ends, the DAO contract `checks if the quorum is met or not`:
        - Did enough people vote? (quorum)
        - Did it get enough “yes” votes? (approval threshold)

6. **Proposal Execution**:
    - If a proposal is approved, the smart contract automatically executes the decision.
    - Here, we use `function signatures` to execute the functions!!!




#  Types of DAO Membership(Voting power)!!!

1. **`Token-Based Membership:`**
    - Usually `permission-less`
    - The governance token holder can cast vote (depends on protocol rules!!!)
    - The token holder should be `delegatedly call` to cast the vote.
    - **Typically used to govern broad decentralized protocols and/or tokens themselves.**


2. **`Share-Based Membership:`** 
    - Share-based DAOs `are more permissioned`
    - Any prospective members can submit a proposal to join the DAO.
    - Shares represent direct voting power and ownership.
    - **Typically used for more closer-knit, human-centric organizations like charities, worker collectives, and investment clubs. Can also govern protocols and tokens as well.**


3. **`Reputation-based membership`**: 
    - **Reputation represents `proof of participation` and grants voting power in the DAO.**
    - Reputation cannot be bought, transferred or delegated
    - DAO members must earn reputation through participation
    - `proof of participation(PoP)` is required to gain proposal and voting power
    - **Typically used for decentralized development and governance of protocols and dapps**


- **Reputation-based >>>  Token-based >>> Share-based**




# Basic DAO protocol mechanism and Different state behaviour

1. **Creating Proposal** -> Any token holder(delegated) can create proposal
2. **Casting Vote** -> After the delay, the proposal becomes Active. Vote started
3. **queuing a proposal** -> If a timelock was set up, the first step to execution is queueing
4. **Executing** -> Once Enough votes and quorum was reached, protocol will execute the function automatically



- We will follow the voting state to perform the specific action based on state:


1. **Pending(0):**
     - Proposal just created.
     - No voting allowed yet
     - It stays here until the voting delay has passed (e.g., 1 block, 1 day).

2. **Active(1):**
     - After the delay, the proposal becomes Active
     - Voting starts
     - Token holders(call delegatedlly)

3. **Defeated(3):**
     - Voting ends.
     - Not enough support or didn’t meet quorum.
     - Proposal is rejected and cannot proceed

4. **Succeeded(4):**
     - Voting ended successfully
     - Enough votes and quorum was reached.

5. **Queued(5):**
     - This introduces a delay before execution(Ex. 2 days) for safety
     - The timelock helps prevent instant execution of critical changes.

6. **Executed(7):**
     - After the TimeLock delay passes, you can now call execute() to run the proposal
     - The calldata in the proposal is used to call the target contract function (e.g., upgrade logic, transfer funds, update parameter).



# condition for Proposal to be succeded

1. **Quorum is reached (a minimum number of votes(in %) has vote for proposal).**
2. More “For” votes than “Against”.

3. If quorum isn’t reached or more votes are “Against”, `it goes to Defeated.`



# Important points for DAO protocol

1. Once a proposal is active, delegates can cast their vote. Note that it is delegates who carry voting power!!!
2. Proposal to be succeded -> Quorum should be reached and enough "for" votes should be there
3. If a timelock was set up, the first step before execution is queueing!!!
4. Any token holder (or only certain ones, depending on rules) can create a proposal.
5. We will use 'function signature' of desired function to be executed in our 'calldata' parameter
6. The actions will be correcetly executed -> By following correct state!!! 



# Sources

1. **Articles and Blog posts for DAO**
    - https://ethereum.org/en/dao/#what-are-daos
    - https://docs.openzeppelin.com/contracts/5.x/governance

2. **Create your own DAO(Aragon)**
   - https://app.aragon.org/dao/ethereum-sepolia-0x97892B9EcB2Fd0987aE5b8Bb537c34e2870400cA/dashboard