// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Splitter is Ownable {

    // создать возможность наборов паков - если отдаешь эти - получаешь эти.
    // параметры сета - количество одинаковых метаданных и количество токенов
    ICyberWayNFT public nft;

    uint256 public tokenCounter;
    // содержит параметры нового токена
    struct Set {
        uint256 colorFrame;
        uint256 rand;
    }

    Set[]public sets;

    constructor(address _nft) {
        nft = ICyberWayNFT(_nft);
    }

    function split(uint256[] memory _donors, uint256 _set) public {
        require(_donors.length == tokenCounter, "Splitter: ");
        // require - todo проверка что метаданные _donors одинаковые
        for(uint i = 0; i < _donors.length; i++) {
            nft.safeTransferFrom(msg.sender, address(this), _donors[i]);
            nft.burn(_donors[i]);
        }

        nft.mint(msg.sender, sets[_set].colorFrame, sets[_set].rand);
        // emit SplitCreated()
    }

    function setCounter(uint256 _newCount) public onlyOwner {
        require(_newCount > 0, "Splitter: incorrect");
        tokenCounter = _newCount;
        // emit CounterModified
    }

    function modifySet(uint256 colorSubstrate, uint256 _colorFrame, uint256 _postFix, uint256 _setId) public onlyOwner {
        //
        // emit SetModified
    }

    function addSet(uint256 colorSubstrate_, uint256 colorFrame_, uint256 postFix_) public onlyOwner {
        // sets.push{colorSubstrate_, colorFrame_, postFix_};
        // emit SetAdded
    }

    function getSet(uint256 _id) public view returns(Set memory) {
        return sets[_id];
    }
}
