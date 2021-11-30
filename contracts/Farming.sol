// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Farming {

    ICyberWayNFT public nft;

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
    }

}
