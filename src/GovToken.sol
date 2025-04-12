// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "lib/openzeppelin-contracts/contracts/utils/Nonces.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 @notice GovToken contract
 * This contract is the basic Governor token used for our DAO contract!!!
 * The contract will contain all the basice minting and burning function
 */


contract GovToken is ERC20, Ownable, ERC20Permit, ERC20Votes {

    constructor()
        ERC20("GovToken", "MTK")
        Ownable(msg.sender)
        ERC20Permit("GovToken")
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address account, uint256 value) public onlyOwner{
        _burn(account, value);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }


}