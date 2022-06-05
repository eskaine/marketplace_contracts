// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Item {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    // string itemName;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
    // string imageUrl;
}

event ItemCreated (
    uint indexed itemId;
    address indexed nftContract;
    uint256 indexed tokenId;
    address seller;
    address owner;
    uint256 price;
    bool sold;
)
