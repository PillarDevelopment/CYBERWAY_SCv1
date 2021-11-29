// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Governance.sol";

contract CyberWayNFT is ERC721, Governance {

    struct CyberWayToken {
        uint256 colorFrame; // Grey, Green, Blue, Purple, Gold
        uint256 rand; // 5 Common,Uncommon,Rare,Epic,Legendary
    }

    CyberWayToken[] public nftTokens;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}


    function mint(address to,
                    uint256 newColorFrame_,
                    uint256 rand_) external onlyGovernance {
        CyberWayToken memory cyberToken = CyberWayToken({colorFrame: newColorFrame_, rand: rand_});
        nftTokens.push(cyberToken);
        uint256 tokenId =  nftTokens.length - 1;
        _mint(to, tokenId);
    }


    function burn(uint256 tokenId) external onlyGovernance {
        _burn(tokenId);
        delete nftTokens[tokenId];
    }


    function getCyberWay(uint256 tokenId) public view returns(CyberWayToken memory) {
        return nftTokens[tokenId];
    }
}
