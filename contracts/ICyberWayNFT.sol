// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICyberWayNFT {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function mint(address to, uint256 kind_, uint256 newColorFrame_, uint256 rand_) external returns(uint256);

    function burn(uint256 tokenId) external;

    function getTokenKind(uint256 tokenId) external view returns(uint256);

    function getTokenColor(uint256 tokenId) external view returns(uint256);

    function getTokenRand(uint256 tokenId) external view returns(uint256);
}
