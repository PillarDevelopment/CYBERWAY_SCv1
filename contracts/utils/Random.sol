// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Random {

    uint256 private _randNonce = 0;

    function _randMod(uint256 modulus) internal returns(uint256) {
        _randNonce++;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _randNonce))) % modulus;}
}