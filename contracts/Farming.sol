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
    ICyberWayNFT public nft;

    uint256 public basicLockPeriod;

    uint256 internal tokenPerBlock = 2e18;

    mapping (address => mapping (uint256 => UserInfo)) public userInfo;

    event NFTDeposited(address sender, uint256 id, uint256 startBlock);
    event NFTWithdrawn(address sender, uint256 id, uint256 amount);
    event NFTEmergencyWithdrawn(address sender, uint256 id, uint256 block);
    event NFTDeposited();

    constructor(address _nft, address _token, uint256 _tokenPerBlock, uint256 _basicLockPeriod) {
        nft = ICyberWayNFT(_nft);
        cyberToken = IERC20(_token);
        tokenPerBlock = _tokenPerBlock;
        basicLockPeriod = _basicLockPeriod;
    }


    function depositFarmingToken(uint256 _id) public {
        require(userInfo[msg.sender][_id].startBlock != 0, "Farming: is exist");
        nft.safeTransferFrom(msg.sender, address(this), _id);
        userInfo[msg.sender][_id].startBlock = block.number;
        //
        //
        emit NFTDeposited(msg.sender, _id, userInfo[msg.sender][_id].startBlock);
    }


    function withdrawFarmingToken(uint256 _id) public {
        require(userInfo[msg.sender][_id].startBlock + basicLockPeriod >= block.number);
        uint256 amount = pendingToken(msg.sender, _id);
        userInfo[msg.sender][_id].startBlock = 0;

        cyberToken.transferFrom(address(this), msg.sender, amount);
        nft.safeTransferFrom(address(this), msg.sender, _id);
        emit NFTWithdrawn(msg.sender, _id, amount);
    }


    function setTokenPerBlock(uint256 _newAmount) public onlyOwner{
        tokenPerBlock = _newAmount;
    }


    function approvalNFTTransfers() public onlyOwner {
      nft.setApprovalForAll(address(this), true);
    }


    function emergencyWithdrawFarmingToken(uint256 _id) public {
        require(userInfo[msg.sender][_id].startBlock != 0, "Farming: Sender isn't token's owner");
        userInfo[msg.sender][_id].startBlock = 0;
        nft.safeTransferFrom(address(this), msg.sender, _id);
        emit NFTEmergencyWithdrawn(msg.sender, _id, block.number);
    }


    function pendingToken(address _user, uint256 _id) public view returns (uint256) {
        return(block.number - userInfo[_user][_id].startBlock) * basicLockPeriod;
    }


    function getCurrentBlockReward() public view returns (uint256) {
        return tokenPerBlock;
    }

}