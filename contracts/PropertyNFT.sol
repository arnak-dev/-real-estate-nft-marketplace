// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PropertyNFT is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;

    struct Property {
        uint256 tokenId;
        string metadataURI;
        uint256 price;
        bool isListed;
        address owner;
    }

    mapping(uint256 => Property) public properties;

    event PropertyMinted(uint256 tokenId, address owner, string metadataURI);
    event PropertyListed(uint256 tokenId, uint256 price);
    event PropertyUnlisted(uint256 tokenId);
    event PropertySold(uint256 tokenId, address newOwner);

    constructor() ERC721("RealEstateNFT", "REALE") {}

    function mintProperty(string memory metadataURI) external {
        uint256 tokenId = nextTokenId++;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, metadataURI);

        properties[tokenId] = Property({
            tokenId: tokenId,
            metadataURI: metadataURI,
            price: 0,
            isListed: false,
            owner: msg.sender
        });

        emit PropertyMinted(tokenId, msg.sender, metadataURI);
    }

    function listProperty(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(price > 0, "Invalid price");

        properties[tokenId].isListed = true;
        properties[tokenId].price = price;

        emit PropertyListed(tokenId, price);
    }

    function unlistProperty(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(properties[tokenId].isListed, "Not listed");

        properties[tokenId].isListed = false;
        properties[tokenId].price = 0;

        emit PropertyUnlisted(tokenId);
    }

    function buyProperty(uint256 tokenId) external payable {
        Property storage prop = properties[tokenId];
        require(prop.isListed, "Not listed for sale");
        require(msg.value >= prop.price, "Insufficient payment");

        address seller = ownerOf(tokenId);

        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);

        prop.owner = msg.sender;
        prop.isListed = false;
        prop.price = 0;

        emit PropertySold(tokenId, msg.sender);
    }
}

