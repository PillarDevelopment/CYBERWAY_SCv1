// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Splitter is Ownable {

    ICyberWayNFT public nft;

    event SplitCompleted(address recipient, uint256 id);

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
    }

    function split(uint256[3] memory _donors) public {
        require(nft.getTokenRand(_donors[0]) == nft.getTokenRand(_donors[1]) &&
                                nft.getTokenRand(_donors[2]) == nft.getTokenRand(_donors[0])
                                && nft.getTokenRand(_donors[0]) < 4, "Splitter: rand not equal or 4");

        require(nft.getTokenKind(_donors[0]) == nft.getTokenKind(_donors[1]) &&
                                nft.getTokenKind(_donors[2]) == nft.getTokenKind(_donors[0]), "Splitter: kind not equal");

        require(nft.getTokenColor(_donors[0]) == nft.getTokenColor(_donors[1]) &&
                                nft.getTokenColor(_donors[2]) == nft.getTokenColor(_donors[0]), "Splitter: color not equal");

        for(uint i = 0; i < _donors.length; i++) {
            nft.safeTransferFrom(msg.sender, address(this), _donors[i]);
            nft.burn(_donors[i]);
        }

        uint256 tokenId = nft.mint(msg.sender, nft.getTokenKind(_donors[0]),
                            nft.getTokenColor(_donors[0]),
                            nft.getTokenRand(_donors[0]) + 1);
        emit SplitCompleted(msg.sender, tokenId);
    }

}