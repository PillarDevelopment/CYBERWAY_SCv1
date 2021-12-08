// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Governance.sol";

contract CyberWayNFT is ERC721, Governance {

    struct CyberWayToken {
        uint8 kind; // 0 - character, 1 - car
        uint8 colorFrame; // Grey, Green, Blue, Purple, Gold
        uint8 rand; // 5 Common,Uncommon,Rare,Epic,Legendary
    }

    CyberWayToken[] public nftTokens;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}


    function mint(address to,
                    uint8 kind_,
                    uint8 newColorFrame_,
                    uint8 rand_) external onlyGovernance returns(uint256){
        CyberWayToken memory cyberToken = CyberWayToken({kind: kind_, colorFrame: newColorFrame_, rand: rand_});
        nftTokens.push(cyberToken);
        uint256 tokenId =  nftTokens.length - 1;
        _mint(to, tokenId);
        return tokenId;
    }


    function burn(uint256 tokenId) external onlyGovernance {
        _burn(tokenId);
        delete nftTokens[tokenId];
    }


    function getTokenKind(uint256 tokenId) public view returns(uint8) {
        return nftTokens[tokenId].kind;
    }


    function getTokenColor(uint256 tokenId) public view returns(uint8) {
        return nftTokens[tokenId].colorFrame;
    }


    function getTokenRand(uint256 tokenId) public view returns(uint8) {
        return nftTokens[tokenId].rand;
    }
}
