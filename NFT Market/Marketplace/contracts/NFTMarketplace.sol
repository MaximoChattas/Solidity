// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Import your custom ERC20 token contract
import "./MaximoChattasToken.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    address payable owner;
    //The fee charged by the marketplace to be allowed to list an NFT
    uint256 listPrice = 0.01 ether;

    // Custom ERC20 token address
    address public customToken;

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 priceInCustomToken;
        bool currentlyListed;
        address customTokenAddress;
        // NFT contract address and ID
        address nftContractAddress;
        uint256 nftTokenId;
    }

    event TokenListedSuccess(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 priceInCustomToken,
        bool currentlyListed
    );

    mapping(uint256 => ListedToken) private idToListedToken;

    constructor(address _customToken) ERC721("NFTMarketplace", "NFTM") {
        owner = payable(msg.sender);
        customToken = _customToken;
    }

    // Function for users to list new NFTs for sale
    function createToken(
        string memory tokenURI,
        uint256 priceInCustomToken
    ) public payable returns (uint) {
        // Increment the tokenId counter
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        // Mint the NFT with tokenId newTokenId to the address who called createToken
        _safeMint(msg.sender, newTokenId);

        // Map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, tokenURI);

        // Helper function to update Global variables and emit an event
        createListedToken(newTokenId, priceInCustomToken);

        return newTokenId;
    }

    // Function for users to list new NFTs for sale
    function createListedToken(
        uint256 tokenId,
        uint256 priceInCustomToken
    ) private {
        require(
            msg.value == listPrice,
            "Please send the correct listing price"
        );

        // Just a sanity check
        require(priceInCustomToken > 0, "Make sure the price isn't negative");

        // Update the mapping of tokenId to Token details, useful for retrieval functions
        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            priceInCustomToken,
            true,
            customToken,
            address(this),
            tokenId
        );

        _transfer(msg.sender, address(this), tokenId);
        // Emit the event for successful transfer. The frontend parses this message and updates the end user
        emit TokenListedSuccess(
            tokenId,
            address(this),
            msg.sender,
            priceInCustomToken,
            true
        );
    }

    // Function to execute the sale using custom ERC20 tokens
    function executeSale(uint256 tokenId) public {
        uint priceInCustomToken = idToListedToken[tokenId].priceInCustomToken;
        address seller = idToListedToken[tokenId].seller;

        IERC20(customToken).approve(address(this), priceInCustomToken);
        // Transfer custom tokens from the buyer to the seller
        IERC20(customToken).transfer(seller, priceInCustomToken);

        idToListedToken[tokenId].currentlyListed = false;
        idToListedToken[tokenId].seller = payable(msg.sender);
        _itemsSold.increment();

        // Actually transfer the NFT to the new owner
        _transfer(address(this), msg.sender, tokenId);
        // Approve the marketplace to sell NFTs on your behalf
        approve(address(this), tokenId);
    }

    // Function to retrieve all the NFTs currently listed for sale
    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint nftCount = _tokenIds.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);
        uint currentIndex = 0;

        for (uint i = 0; i < nftCount; i++) {
            uint currentId = i + 1;
            ListedToken storage currentItem = idToListedToken[currentId];

            if (currentItem.currentlyListed) {
                tokens[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        // Resize the tokens array to remove empty slots caused by filtered NFTs
        assembly {
            mstore(tokens, currentIndex)
        }

        return tokens;
    }

    // Function to retrieve all the NFTs that the current user is the owner or seller of
    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        // Important to get a count of all the NFTs that belong to the user before we can make an array for them
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                itemCount += 1;
            }
        }

        // Once you have the count of relevant NFTs, create an array then store all the NFTs in it
        ListedToken[] memory items = new ListedToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                uint currentId = i + 1;
                ListedToken storage currentItem = idToListedToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Function to update the listing price
    function updateListPrice(uint256 _listPrice) public payable {
        require(
            owner == msg.sender,
            "Only the owner can update the listing price"
        );
        listPrice = _listPrice;
    }

    // Function to get the current listing price
    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    // Function to get the details of the latest listed token
    function getLatestIdToListedToken()
        public
        view
        returns (ListedToken memory)
    {
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

    // Function to get the details of a listed token by its tokenId
    function getListedTokenForId(
        uint256 tokenId
    ) public view returns (ListedToken memory) {
        return idToListedToken[tokenId];
    }

    // Function to get the current token ID
    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }
}
