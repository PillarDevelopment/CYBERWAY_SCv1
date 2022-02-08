// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Governance.sol";

contract CyberWayNFT is ERC721, Governance {
    using Strings for uint256;

    struct CyberWayToken {
        uint8 kind; // 0 - character, 1 - car
        uint8 colorFrame; // Grey, Green, Blue, Purple, Gold
        uint8 rand; // 5 Common,Uncommon,Rare,Epic,Legendary
    }

    CyberWayToken[] private _nftTokens;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }


    function mint(address to,
                    uint8 kind_,
                    uint8 newColorFrame_,
                    uint8 rand_) external onlyGovernance returns(uint256) {
        CyberWayToken memory cyberToken = CyberWayToken({kind: kind_, colorFrame: newColorFrame_, rand: rand_});
        _nftTokens.push(cyberToken);
        uint256 tokenId =  _nftTokens.length - 1;
        _mint(to, tokenId);
        return tokenId;
    }


    function burn(uint256 tokenId) external onlyGovernance {
        _burn(tokenId);
        delete _nftTokens[tokenId];
    }


    function getTokenKind(uint256 tokenId) public view returns(uint8) {
        return _nftTokens[tokenId].kind;
    }


    function getTokenColor(uint256 tokenId) public view returns(uint8) {
        return _nftTokens[tokenId].colorFrame;
    }


    function getTokenRand(uint256 tokenId) public view returns(uint8) {
        return _nftTokens[tokenId].rand;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,"color=",uint256(getTokenColor(tokenId)).toString(),"&rare=",uint256(getTokenRand(tokenId)).toString(),"&kind=",uint256(getTokenKind(tokenId)).toString())) : "";
    }


    function _baseURI() internal override pure returns (string memory) {
        return "https://cybernft.io/nfts?"; // todo
    }
}