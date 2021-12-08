// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Farming is Ownable{

    mapping(address => mapping(uint256 => uint256))public userInfo; //  user => (tokenId => timeToLock)

    IERC20 public cyberToken;
    ICyberWayNFT public cyberNft;

    uint256 public basicLockPeriod = 201600; //blocks -  3 sec per block / 7 days
    uint256 private _tokenPerBlock = 2e18; // 2 tokens

    event NFTDeposited(address sender, uint256 id, uint256 startBlock);
    event NFTWithdrawn(address sender, uint256 id, uint256 amount);
    event NFTEmergencyWithdrawn(address sender, uint256 id, uint256 block);
    event NFTDeposited();

    constructor(address nft, address token) {
        cyberNft = ICyberWayNFT(nft);
        cyberToken = IERC20(token);
    }


    function depositFarmingToken(uint256 id) public {
        require(userInfo[msg.sender][id] == 0, "Farming: is exist");
        cyberNft.transferFrom(msg.sender, address(this), id);
        userInfo[msg.sender][id] = block.number;
        emit NFTDeposited(msg.sender, id, userInfo[msg.sender][id]);
    }


    function withdrawFarmingToken(uint256 id) public {
        require(userInfo[msg.sender][id] + basicLockPeriod <= block.number, "Farming: incorrect period");
        require(userInfo[msg.sender][id] != 0, "Farming: Sender isn't token's owner");

        uint256 amount = pendingToken(msg.sender, id);
        userInfo[msg.sender][id] = 0;

        cyberToken.transfer(msg.sender, amount);
        cyberNft.transferFrom(address(this), msg.sender, id);
        emit NFTWithdrawn(msg.sender, id, amount);
    }


    // WARNING: don't update, when you have active farmers, you will have incorrect amount
    function setTokenPerBlock(uint256 newAmount) public onlyOwner {
        require(newAmount != 0, "Farming:");
        _tokenPerBlock = newAmount;
    }


    // WARNING: don't update, when you have active farmers, you will have incorrect amount
    function setBasicLockPeriod(uint256 newAmount) public onlyOwner {
        require(newAmount != 0, "Farming: zero amount");
        basicLockPeriod = newAmount;
    }


    function emergencyWithdrawFarmingToken(uint256 id) public {
        require(userInfo[msg.sender][id] != 0, "Farming: Sender isn't token's owner");
        userInfo[msg.sender][id] = 0;
        cyberNft.transferFrom(address(this), msg.sender, id);
        emit NFTEmergencyWithdrawn(msg.sender, id, block.number);
    }


    function pendingToken(address user, uint256 id) public view returns (uint256) {
        require(userInfo[user][id] != 0, "Farming: User doesn't exist");
        return (block.number - userInfo[user][id]) * _tokenPerBlock;
    }


    function getCurrentBlockReward() public view returns (uint256) {
        return _tokenPerBlock;
    }
}
