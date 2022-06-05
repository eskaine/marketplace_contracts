// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";
import { Item, ItemCreated } from "./models/Item.sol";

contract MarketPlace is ReentrancyGuard {
    using Counters for Counters.Counter;

    address payable owner;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    mapping(uint256 => Item) private items;
    mapping(address => uint256[]) private itemsListedBySellers; 
 
    uint256[] items_listed; 

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createItem(
        address nftContract,
        uint256 tokenId,
        uint256 price, 
    ) public payable nonReentrant {
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

        itemsListedBySellers[msg.sender].push(itemId);
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

    function itemSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        uint price = items[itemId].price;
        uint tokenId = items[itemId].tokenId;
        require(msg.value == price, "Price must match the asking price to complete the purchase");

        items[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        items[itemId].owner = payable(msg.sender);
        items[itemId].solder = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    function removeFromList( uint256 id, address user ) private onlyNFTOwner(id) {
        delete itemsbyaddress[user][id];
    }

    //https://ipfs.infura.io/ipfs/Qmf6isejKuRVLxWyY1NpMudrGp97xo5NCtamynbKrssjBi


    function editNFT(uint256 id, string memory name, uint256 price, string memory imageUrl, bool isListed) public onlyNFTOwner(id) {
        items[id].name = name;
        items[id].price = price;
        items[id].imageUrl = imageUrl;
        items[id].isListed = false;

        if(isListed) {
            require(price >= 0);
            items[id].isListed = true;
        }
    }

    function getAllItems() public view returns (Item[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint index = 0;

        Item[] memory itemsList = new Item[](unsoldItemCount);
        
        for (uint i = 0; i < totalNFTs; i++)
        {
            if(items[i + 1].owner == address(0)) {
                uint id = items[i + 1].itemId;
                Item storage item = items[id];
                itemsList[index] = item;
                index++;
            }
        }

        return itemsList;
    }

    function getUserNFTList(address user) public view returns (Item[] memory) {
        uint256[] memory useritems = itemsbyaddress[user];
        nft[] memory nfts = new nft[](useritems.length+1);
        
        for ( uint i=0; i < useritems.length; i++)
        {
            nft storage item = items[i];
            nfts[i] = item;
        }
        return (nfts);
    }

    modifier notContractOwner() {
        require(msg.sender != owner);
        _;
    }

    modifier onlyNFTOwner(uint256 id) {
        require(msg.sender == items[id].currentOwner);
        _;
    }
}
