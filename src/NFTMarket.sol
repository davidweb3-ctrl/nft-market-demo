// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {MyERC20, IERC20TokenReceiver} from "./MyERC20.sol";
import {MyERC721} from "./MyERC721.sol";

contract NFTMarket is IERC20TokenReceiver, IERC721Receiver {
    struct Listing {
        address seller;
        MyERC20 paymentToken;
        uint256 price;
    }

    MyERC721 public immutable collection;

    mapping(uint256 tokenId => Listing) public listings;

    event Listed(address indexed seller, uint256 indexed tokenId, address indexed paymentToken, uint256 price);
    event Purchase(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price,
        uint256 amountPaid
    );

    constructor(MyERC721 _collection) {
        collection = _collection;
    }

    function getListing(uint256 tokenId) external view returns (Listing memory listing) {
        listing = listings[tokenId];
    }

    function list(uint256 tokenId, MyERC20 paymentToken, uint256 price) external {
        require(listings[tokenId].seller == address(0), "NFTMarket: already listed");
        require(collection.ownerOf(tokenId) == msg.sender, "NFTMarket: not token owner");
        require(address(paymentToken) != address(0), "NFTMarket: invalid payment token");
        require(price > 0, "NFTMarket: invalid price");

        listings[tokenId] = Listing({seller: msg.sender, paymentToken: paymentToken, price: price});

        collection.safeTransferFrom(msg.sender, address(this), tokenId);

        emit Listed(msg.sender, tokenId, address(paymentToken), price);
    }

    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFTMarket: not listed");
        require(msg.sender != listing.seller, "NFTMarket: seller cannot buy");
        require(collection.ownerOf(tokenId) == address(this), "NFTMarket: NFT not in escrow");

        delete listings[tokenId];

        require(
            listing.paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "NFTMarket: payment failed"
        );

        collection.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Purchase(msg.sender, listing.seller, tokenId, address(listing.paymentToken), listing.price, listing.price);
    }

    function tokensReceived(address from, uint256 amount, bytes calldata data) external override {
        uint256 tokenId = abi.decode(data, (uint256));

        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFTMarket: not listed");
        require(msg.sender == address(listing.paymentToken), "NFTMarket: unsupported token");
        require(from != listing.seller, "NFTMarket: seller cannot buy");
        require(amount >= listing.price, "NFTMarket: insufficient payment");
        require(collection.ownerOf(tokenId) == address(this), "NFTMarket: NFT not in escrow");

        delete listings[tokenId];

        require(listing.paymentToken.transfer(listing.seller, listing.price), "NFTMarket: payout failed");

        if (amount > listing.price) {
            require(listing.paymentToken.transfer(from, amount - listing.price), "NFTMarket: refund failed");
        }

        collection.safeTransferFrom(address(this), from, tokenId);

        emit Purchase(from, listing.seller, tokenId, address(listing.paymentToken), listing.price, amount);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external view override returns (bytes4) {
        require(msg.sender == address(collection), "NFTMarket: unsupported NFT");
        return IERC721Receiver.onERC721Received.selector;
    }
}
