// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";
import { IItem } from "./models/Item.sol";

contract MarketPlace is IItem, ReentrancyGuard {
    using Counters for Counters.Counter;

    address payable owner;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    mapping(uint256 => Item) private items;

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();
                
        items[itemId] = Item(
            itemId, 
            nftContract, 
            tokenId, 
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit ItemCreated(
            itemId, 
            nftContract, 
            tokenId, 
            msg.sender,
            address(0),
            price,
            false
        );
    }

    function itemSale(address nftContract,  uint256 itemId) public payable nonReentrant {
        uint price = items[itemId].price;
        uint tokenId = items[itemId].tokenId;
        require(msg.value == price, "Price must match the asking price to complete the purchase");

        items[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        items[itemId].owner = payable(msg.sender);
        items[itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    // function editNFT(uint256 id, string memory name, uint256 price, string memory imageUrl, bool isListed) public onlyNFTOwner(id) {
    //     items[id].name = name;
    //     items[id].price = price;
    //     items[id].imageUrl = imageUrl;
    //     items[id].isListed = false;

    //     if(isListed) {
    //         require(price >= 0);
    //         items[id].isListed = true;
    //     }
    // }

    function getAllItems() public view returns (Item[] memory) {
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();

        Item[] memory itemsList = mapItemsToArray(address(0), unsoldItemCount, 'owner');

        return itemsList;
    }

    function getUserItems() public view returns (Item[] memory) {
        uint itemCount = _itemIds.current();
        uint userItemCount = 0;
        
        for (uint i=0; i < itemCount; i++) {
            if(items[i + 1].owner == msg.sender) {
                userItemCount++;
            }
        }

        Item[] memory itemsList = mapItemsToArray(msg.sender, userItemCount, 'owner');

        return itemsList;
    }

    function getItemsCreated() public view returns (Item[] memory) {
        uint itemCount = _itemIds.current();
        uint userItemCount = 0;
        
        for (uint i=0; i < itemCount; i++) {
            if(items[i + 1].seller == msg.sender) {
                userItemCount++;
            }
        }

        Item[] memory itemsList = mapItemsToArray(msg.sender, userItemCount, 'seller');

        return itemsList;
    }

    function mapItemsToArray(address addressToCheck, uint toMapCount, bytes32 keyName) private view returns (Item[] memory) {
        uint itemCount = _itemIds.current();
        uint index = 0;
        Item[] memory itemsList = new Item[](toMapCount);

        for (uint i=0; i < itemCount; i++)
        {
            address itemAddress;

            if(keyName == 'owner') {
                itemAddress = items[i + 1].owner;
            } else if(keyName == 'seller') {
                itemAddress = items[i + 1].seller;
            }

            if(itemAddress == addressToCheck) {
                uint id = items[i + 1].itemId;
                Item storage item = items[id];
                itemsList[index] = item;
                index++;
            }
        }

        return itemsList;
    }

    modifier notContractOwner() {
        require(msg.sender != owner);
        _;
    }

    // modifier onlyNFTOwner(uint256 id) {
    //     require(msg.sender == items[id].currentOwner);
    //     _;
    // }
}
