// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICyberWayNFT {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function mint(address to, uint8 kind_, uint8 newColorFrame_, uint8 rand_) external returns(uint256);

    function burn(uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;

    function getTokenKind(uint256 tokenId) external view returns(uint8);

    function getTokenColor(uint256 tokenId) external view returns(uint8);

    function getTokenRand(uint256 tokenId) external view returns(uint8);
}
