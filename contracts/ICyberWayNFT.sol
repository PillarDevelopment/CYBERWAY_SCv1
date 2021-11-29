// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICyberWayNFT {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function mint(address to, uint256 newColorFrame_, uint256 rand_) external;

    function burn(uint256 tokenId) external;
}
