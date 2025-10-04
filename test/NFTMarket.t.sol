// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {MyERC721} from "../src/MyERC721.sol";

contract NFTMarketTest is Test {
    NFTMarket internal market;
    MyERC20 internal paymentToken;
    MyERC721 internal collection;

    address internal constant ALICE = address(0xA11CE);
    address internal constant BOB = address(0xB0B);

    function setUp() public {
        paymentToken = new MyERC20();
        collection = new MyERC721();
        market = new NFTMarket(paymentToken, collection);

        // Give initial ERC20 supply to test contract
        // Already minted to address(this) per MyERC20 constructor

        // Mint an NFT to ALICE
        collection.mint(ALICE, "ipfs://token-1");

        // Give ERC20 tokens to BOB
        paymentToken.transfer(BOB, 1_000 ether);
    }

    function testListAndBuyNFT() public {
        uint256 tokenId = 1;
        uint256 price = 100 ether;

        vm.prank(ALICE);
        collection.approve(address(market), tokenId);

        vm.prank(ALICE);
        market.list(tokenId, price);

        vm.prank(BOB);
        paymentToken.approve(address(market), price);

        vm.prank(BOB);
        market.buyNFT(tokenId);

        assertEq(collection.ownerOf(tokenId), BOB);
        assertEq(paymentToken.balanceOf(ALICE), price);
    }

    function testBuyViaTransferWithCallback() public {
        uint256 tokenId = 1;
        uint256 price = 150 ether;

        vm.prank(ALICE);
        collection.approve(address(market), tokenId);

        vm.prank(ALICE);
        market.list(tokenId, price);

        vm.prank(BOB);
        paymentToken.approve(address(market), price);

        vm.prank(BOB);
        paymentToken.transferWithCallback(address(market), price, abi.encode(tokenId));

        assertEq(collection.ownerOf(tokenId), BOB);
        assertEq(paymentToken.balanceOf(ALICE), price);
    }

    function test_RevertWhen_TokensReceivedInsufficientPayment() public {
        uint256 tokenId = 1;
        uint256 price = 200 ether;

        vm.prank(ALICE);
        collection.approve(address(market), tokenId);
        vm.prank(ALICE);
        market.list(tokenId, price);

        vm.prank(BOB);
        paymentToken.approve(address(market), price - 1 ether);

        vm.prank(BOB);
        vm.expectRevert("NFTMarket: insufficient payment");
        paymentToken.transferWithCallback(address(market), price - 1 ether, abi.encode(tokenId));
    }
}
