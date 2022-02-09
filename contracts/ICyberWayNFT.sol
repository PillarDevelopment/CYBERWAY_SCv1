// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICyberWayNFT {

    function transferFrom(address from, address to, uint256 tokenId) external;

    function mint(address to, uint8 kind_, uint16 person_, uint8 rand_) external returns(uint256);

    function burn(uint256 tokenId) external;

    function getTokenKind(uint256 tokenId) external view returns(uint8);

    function getTokenPerson(uint256 tokenId) external view returns(uint8);

    function getTokenRand(uint256 tokenId) external view returns(uint8);
}
