// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICyberWayNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Farming is Ownable{

    struct UserInfo {
        uint256 id;
        uint256 startBlock;
    }

    IERC20 public cyberToken;
    ICyberWayNFT public nft;

    uint256 public basicLockPeriod;

    uint256 internal tokenPerBlock = 2;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    
    constructor(address _nft, address _token, uint256 _tokenPerBlock, uint256 _basicLockPeriod) {
        nft = ICyberWayNFT(_nft);
        cyberToken = IERC20(_token);
        tokenPerBlock = _tokenPerBlock;
        basicLockPeriod = _basicLockPeriod;
    }


    function setTokenPerBlock(uint256 _newAmount) public onlyOwner{
        tokenPerBlock = _newAmount;
    }


    function approvalNFTTransfers() public onlyOwner {
      //  nft.setApprovalForAll(address(this), true); // todo
    }


    function getCurrentBlockReward() public view returns (uint256) {
        return tokenPerBlock;
    }


    function depositFarmingToken(uint256 _id) public { }


    function withdrawFarmingToken(uint256 _id) public {}


    function emergencyWithdrawFarmingToken(uint256 _id) public {}


    function pendingToken(address _user, uint256 _id) external view returns (uint256) {
        return 1; // todo
    }

}