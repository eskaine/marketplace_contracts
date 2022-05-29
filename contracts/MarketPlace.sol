// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MarketPlace {
    address public owner;
    uint256 private totalNFTs;

    constructor() {
        owner = msg.sender;
    }
    
    struct nft {
        uint256 id;
        string name;
        address currentOwner;
        uint256 price;
        string imageUrl;
        bool isListed;
    }

    mapping(uint256 => nft) public items;
    mapping(address => uint256[]) private itemsbyaddress; 
 
    uint256[] items_listed; 

    function addNFT(string memory name, uint256 price, string memory imageUrl, bool isListed) public payable returns(uint256)  {
        require(msg.value > 0.01 ether);

        totalNFTs++;
        uint256 newItemId = totalNFTs;
        
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
        nft[] memory nfts = new nft[](totalNFTs);
        
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
