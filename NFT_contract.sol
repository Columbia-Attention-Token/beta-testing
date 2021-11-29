// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

/* Import the OpenZeppelin implementation of the ERC721 contract */ 

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/* Write a digital asset contract that inherits the ERC721 standard */
/* Counters import allows us to have access to a counter utility that lets us create a number 
   and then increment from that number everytime a function gets called. For this comtract,
   it gives us access to the digital asset unique identifier */ 

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Digital Marketplace", "JPM") {
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