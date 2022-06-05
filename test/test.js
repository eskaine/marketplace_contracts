const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MarketPlace", function () {
  it("Should create market sale", async function () {
    const MarketPlace = await ethers.getContractFactory("MarketPlace");
    const marketPlace = await MarketPlace.deploy();
    await marketPlace.deployed();
    const marketPlaceAddress = marketPlace.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketPlaceAddress);
    await nft.deployed();
    const nftAddress = nft.address;

    let listingPrice = await marketPlace.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits('100', 'ether');

    await nft.createToken("https://www.sampletokenlink.com");
    await nft.createToken("https://www.sampletokenlink2.com");

    await marketPlace.createItem(nftAddress, 1, auctionPrice, {value: listingPrice});
    await marketPlace.createItem(nftAddress, 2, auctionPrice, {value: listingPrice});

    const [_, buyerAddress] = await ethers.getSigners();
    
    await marketPlace.connect(buyerAddress).itemSale(nftAddress, 1, {value: auctionPrice});
  
    let items = await marketPlace.getAllItems();
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId);

      return {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      };
    }));

    console.log({items});
  });
});
