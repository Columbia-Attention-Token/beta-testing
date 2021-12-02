// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

/* Import the OpenZeppelin implementation of the ERC721 contract, to be used for the NFT contract */ 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/* For the marketplace contract, we imported the ReEntry Guard modifier which is used for security
   purposes when making recursive calls (calling one contract from another) */

import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 

/* Write a digital asset contract, called NFT, that inherits the ERC721 standard */
/* Counters import allows us to have access to a counter utility that lets us create a number 
   and then increment from that number everytime a function gets called. For this comtract,
   it gives us access to the digital asset unique identifier */ 

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Digital Asset Marketplace", "JPM") {
        contractAddress = marketplaceAddress;
    }

/* setTokenURI allows us to set the NFT URI (like IPFS url that holds the name, description,
   and NFT image property  */
/* setApprovalForAll from within ERC721 allows us to pass in the contractaddress we want to give 
   permission to make transfers on behalf of */  

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}

/* Write a smart contract for the digital asset marketplace, named NFTMarket. */
/* itemIds variable represents the unique identifier for marketplace item */ 
/* itemsSold variable represents the number of items sold */ 

contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint256 listingPrice = 10.0 ether;

  constructor() {
    owner = payable(msg.sender);
  }

/* MarketItem structure contains the market item unique identifier, the contract address for digital asset,
   the token ID for the asset, the seller [person listing item for sale] address, the owner address (which 
   will be set to an empty address because future new owner is unknown), and price which will be defined by 
   the user selling item */

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
  }

/* mapping is set to IDtoMarketItem which will give us a key value pair where we can pass in the market item ID
   and return the market item so can retrieve the metadata for items based on their item id */

  mapping(uint256 => MarketItem) private idToMarketItem;

/* Define an event for when a new item is created. This will allows us to emit a new event every time a item is purchased.
   This is useful for event listeners in your application but also if we want to use the graph protocol to index the data
   from a smart contract */

  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price
  );

  function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
    return idToMarketItem[marketItemId];
  }

  function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Price must be equal to listing price");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
/* Seller address is msg.sender */
/* Since item is placed for sale, owner address is unknown and is set to an empty address */

    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price
    );

/* Transfer ownership of digital asset & Emit event */

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price
    );
  }

/* Create the sale of digital item */

  function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

/* Retrieve the number of items available for sale */

  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
   
    return items;
  }

/* Retrieve items we have purchased/we own */

  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

/* *** Confirm if owner is the seller and not an empty address *** */

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}