// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Random {

    // Initializing the state variable
    uint randNonce = 0;

    // Defining a function to generate
    // a random number
    function randMod(uint _modulus) internal returns(uint256) {
        // increase nonce
        randNonce++;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;}
}