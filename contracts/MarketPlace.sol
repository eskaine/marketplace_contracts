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
    mapping(address => uint256[]) private itemsbyaddress; 
 
    uint256[] items_listed; 

    function addNFT(string memory name, uint256 price, string memory imageUrl, bool isListed) public payable returns(uint256)  {
        require(msg.value > 0.01 ether);

        _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        
        
        nft memory newNFT = nft(
            newItemId, name, msg.sender, price, imageUrl, isListed
        );
        
        items[newItemId] = newNFT;
        itemsbyaddress[msg.sender].push(newItemId);

        return newItemId;
    }

    function removeFromList( uint256 id, address user ) private onlyNFTOwner(id) {
        delete itemsbyaddress[user][id];
    }

    // function buyNFT( uint256 id ) public payable notContractOwner {
    //     require( msg.value >= items[id].price );

        
    //     address payable sendTo = payable(items[id].currentOwner);
    //     // send token's worth of ethers to the owner
    //     sendTo.transfer(msg.value);

    //     removeFromList(id, items[id].currentOwner);

    //     //update to new owner of the nft
    //     items[id].currentOwner = msg.sender;
    //     itemsbyaddress[msg.sender].push( id );
    // }

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

    function getAllListedNFT() public view returns (nft[] memory) {
        nft[] memory nfts = new nft[](_nftIds);
        
        for (uint i = 0; i < totalNFTs; i++)
        {
            nft storage item = items[i];
            nfts[i] = item;
        }

        return nfts;
    }

    function getUserNFTList(address user) public view returns (nft[] memory) {
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
