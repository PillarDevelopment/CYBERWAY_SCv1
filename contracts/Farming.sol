// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Farming is Ownable{

    struct UserInfo {
        uint256 startBlock;
        //bool isActive;
    }

    IERC20 public cyberToken;
    ICyberWayNFT public cyberNft;

    uint256 public basicLockPeriod;

    uint256 private _tokenPerBlock = 2e18;

    mapping (address => mapping (uint256 => UserInfo)) public userInfo;

    event NFTDeposited(address sender, uint256 id, uint256 startBlock);
    event NFTWithdrawn(address sender, uint256 id, uint256 amount);
    event NFTEmergencyWithdrawn(address sender, uint256 id, uint256 block);
    event NFTDeposited();

    constructor(address nft, address token, uint256 newTokenPerBlock, uint256 newBasicLockPeriod) {
        cyberNft = ICyberWayNFT(nft);
        cyberToken = IERC20(token);
        _tokenPerBlock = newTokenPerBlock;
        basicLockPeriod = newBasicLockPeriod;
    }


    function depositFarmingToken(uint256 id) public {
        require(userInfo[msg.sender][id].startBlock != 0, "Farming: is exist");
        cyberNft.safeTransferFrom(msg.sender, address(this), id);
        userInfo[msg.sender][id].startBlock = block.number;
        //
        //
        emit NFTDeposited(msg.sender, id, userInfo[msg.sender][id].startBlock);
    }


    function withdrawFarmingToken(uint256 id) public {
        require(userInfo[msg.sender][id].startBlock + basicLockPeriod >= block.number, "Farming: incorrect period");
        uint256 amount = pendingToken(msg.sender, id);
        userInfo[msg.sender][id].startBlock = 0;

        cyberToken.transferFrom(address(this), msg.sender, amount);
        cyberNft.safeTransferFrom(address(this), msg.sender, id);
        emit NFTWithdrawn(msg.sender, id, amount);
    }


    function setTokenPerBlock(uint256 _newAmount) public onlyOwner{
        _tokenPerBlock = _newAmount;
    }


    function approvalNFTTransfers() public onlyOwner {
        cyberNft.setApprovalForAll(address(this), true);
    }


    function emergencyWithdrawFarmingToken(uint256 id) public {
        require(userInfo[msg.sender][id].startBlock != 0, "Farming: Sender isn't token's owner");
        userInfo[msg.sender][id].startBlock = 0;
        cyberNft.safeTransferFrom(address(this), msg.sender, id);
        emit NFTEmergencyWithdrawn(msg.sender, id, block.number);
    }


    function pendingToken(address _user, uint256 _id) public view returns (uint256) {
        return(block.number - userInfo[_user][_id].startBlock) * basicLockPeriod;
    }


    function getCurrentBlockReward() public view returns (uint256) {
        return _tokenPerBlock;
    }

}