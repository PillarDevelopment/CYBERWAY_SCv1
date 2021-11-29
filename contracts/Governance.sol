// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Governance is Ownable{

    modifier onlyGovernance() {
        require(governance[_msgSender()], "CYBER_NFT: caller is not the governance");
        _;
    }

    mapping(address => bool) public governance;

    function isGovernance(address governance_) public view returns(bool) {
        return governance[governance_];
    }

    function addGovernance(address _member) public onlyOwner {
        governance[_member] = true;
    }

    function removeGovernance(address _member) public onlyOwner {
        governance[_member] = false;
    }
}
