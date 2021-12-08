// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Merger is Ownable {

    ICyberWayNFT public nft;

    event SplitCompleted(address recipient, uint256 id);

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
    }

    function merge(uint256[3] memory _donors) public {
        require(nft.getTokenRand(_donors[0]) == nft.getTokenRand(_donors[1]) &&
                                nft.getTokenRand(_donors[2]) == nft.getTokenRand(_donors[0])
                                && nft.getTokenRand(_donors[0]) < 4,"Merger: rand not equal or max");

        require(nft.getTokenKind(_donors[0]) == nft.getTokenKind(_donors[1]) &&
                                nft.getTokenKind(_donors[2]) == nft.getTokenKind(_donors[0]),"Merger:kind notEqual");

        require(nft.getTokenColor(_donors[0]) == nft.getTokenColor(_donors[1]) &&
                                nft.getTokenColor(_donors[2]) == nft.getTokenColor(_donors[0]),"Merger:color notEqual");

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
