// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {MyERC20, IERC20TokenReceiver} from "./MyERC20.sol";
import {MyERC721} from "./MyERC721.sol";

contract NFTMarket is IERC20TokenReceiver, IERC721Receiver {
    struct Listing {
        address seller;
        uint256 price;
    }

    MyERC20 public immutable paymentToken;
    MyERC721 public immutable collection;

    mapping(uint256 tokenId => Listing) public listings;

    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 price);

    constructor(MyERC20 _paymentToken, MyERC721 _collection) {
        paymentToken = _paymentToken;
        collection = _collection;
    }

    function list(uint256 tokenId, uint256 price) external {
        require(collection.ownerOf(tokenId) == msg.sender, "NFTMarket: not token owner");
        require(price > 0, "NFTMarket: invalid price");
        require(listings[tokenId].seller == address(0), "NFTMarket: already listed");

        listings[tokenId] = Listing({seller: msg.sender, price: price});

        collection.safeTransferFrom(msg.sender, address(this), tokenId);

        emit Listed(msg.sender, tokenId, price);
    }

    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFTMarket: not listed");
        require(msg.sender != listing.seller, "NFTMarket: seller cannot buy");
        require(collection.ownerOf(tokenId) == address(this), "NFTMarket: NFT not in escrow");

        delete listings[tokenId];

        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "NFTMarket: payment failed");

        collection.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Purchase(msg.sender, listing.seller, tokenId, listing.price);
    }

    function tokensReceived(address from, uint256 amount, bytes calldata data) external override {
        require(msg.sender == address(paymentToken), "NFTMarket: unsupported token");

        uint256 tokenId = abi.decode(data, (uint256));

        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFTMarket: not listed");
        require(from != listing.seller, "NFTMarket: seller cannot buy");
        require(amount >= listing.price, "NFTMarket: insufficient payment");
        require(collection.ownerOf(tokenId) == address(this), "NFTMarket: NFT not in escrow");

        delete listings[tokenId];

        require(paymentToken.transfer(listing.seller, listing.price), "NFTMarket: payout failed");

        if (amount > listing.price) {
            require(paymentToken.transfer(from, amount - listing.price), "NFTMarket: refund failed");
        }

        collection.safeTransferFrom(address(this), from, tokenId);

        emit Purchase(from, listing.seller, tokenId, listing.price);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external view override returns (bytes4) {
        require(msg.sender == address(collection), "NFTMarket: unsupported NFT");
        return IERC721Receiver.onERC721Received.selector;
    }
}
