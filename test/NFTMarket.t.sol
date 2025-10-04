// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {MyERC721} from "../src/MyERC721.sol";

contract NFTMarketTest is Test {
    NFTMarket internal market;
    MyERC721 internal collection;
    MyERC20 internal tokenA;
    MyERC20 internal tokenB;

    address internal constant ALICE = address(0xA11CE);
    address internal constant BOB = address(0xB0B);

    event Listed(address indexed seller, uint256 indexed tokenId, address indexed paymentToken, uint256 price);
    event Purchase(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price,
        uint256 amountPaid
    );

    function setUp() public {
        collection = new MyERC721();
        market = new NFTMarket(collection);
        tokenA = new MyERC20();
        tokenB = new MyERC20();

        collection.mint(ALICE, "ipfs://token-1");
        collection.mint(ALICE, "ipfs://token-2");

        deal(address(tokenA), address(this), tokenA.balanceOf(address(this)) + 2_000 ether);
        deal(address(tokenB), address(this), tokenB.balanceOf(address(this)) + 2_000 ether);

        tokenA.transfer(ALICE, 1_000 ether);
        tokenA.transfer(BOB, 1_000 ether);
        tokenB.transfer(ALICE, 1_000 ether);
        tokenB.transfer(BOB, 1_000 ether);
    }

    function testListSuccess() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        vm.expectEmit(true, true, true, true);
        emit Listed(ALICE, 1, address(tokenA), 100 ether);
        market.list(1, tokenA, 100 ether);
        vm.stopPrank();

        NFTMarket.Listing memory listing = market.getListing(1);
        assertEq(listing.seller, ALICE);
        assertEq(address(listing.paymentToken), address(tokenA));
        assertEq(listing.price, 100 ether);
        assertEq(collection.ownerOf(1), address(market));
    }

    function testListFailWhenNotOwner() public {
        vm.expectRevert("NFTMarket: not token owner");
        market.list(1, tokenA, 100 ether);
    }

    function testListFailWhenZeroPriceOrToken() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        vm.expectRevert("NFTMarket: invalid price");
        market.list(1, tokenA, 0);

        vm.expectRevert("NFTMarket: invalid payment token");
        market.list(1, MyERC20(address(0)), 100 ether);
        vm.stopPrank();
    }

    function testListFailWhenAlreadyListed() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenA, 100 ether);

        vm.expectRevert("NFTMarket: already listed");
        market.list(1, tokenA, 100 ether);
        vm.stopPrank();
    }

    function testBuyNFTSuccess() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenA, 100 ether);
        vm.stopPrank();

        vm.startPrank(BOB);
        tokenA.approve(address(market), 100 ether);
        vm.expectEmit(true, true, true, true);
        emit Purchase(BOB, ALICE, 1, address(tokenA), 100 ether, 100 ether);
        market.buyNFT(1);
        vm.stopPrank();

        assertEq(collection.ownerOf(1), BOB);
        assertEq(tokenA.balanceOf(ALICE), 1_100 ether);
        assertZeroBalances();
    }

    function testBuyNFTFails() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenA, 100 ether);
        vm.stopPrank();

        vm.prank(ALICE);
        vm.expectRevert("NFTMarket: seller cannot buy");
        market.buyNFT(1);

        vm.prank(BOB);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        market.buyNFT(1);

        vm.prank(BOB);
        tokenA.approve(address(market), 100 ether);
        vm.prank(BOB);
        market.buyNFT(1);

        address charlie = address(0x1234);
        vm.startPrank(charlie);
        deal(address(tokenA), charlie, 100 ether);
        tokenA.approve(address(market), 100 ether);
        vm.expectRevert("NFTMarket: not listed");
        market.buyNFT(1);
        vm.stopPrank();
    }

    function testBuyNFTFailsWhenTransferNotApproved() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenA, 100 ether);
        vm.stopPrank();

        vm.prank(BOB);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        market.buyNFT(1);
    }

    function testBuyWithCallbackExactPayment() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenB, 200 ether);
        vm.stopPrank();

        vm.startPrank(BOB);
        tokenB.approve(address(market), type(uint256).max);
        vm.expectEmit(true, true, true, true);
        emit Purchase(BOB, ALICE, 1, address(tokenB), 200 ether, 200 ether);
        tokenB.transferWithCallback(address(market), 200 ether, abi.encode(uint256(1)));
        vm.stopPrank();

        assertEq(collection.ownerOf(1), BOB);
        assertEq(tokenB.balanceOf(ALICE), 1_200 ether);
        assertZeroBalances();
    }

    function testBuyWithCallbackOverpayRefund() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenB, 200 ether);
        vm.stopPrank();

        vm.startPrank(BOB);
        tokenB.approve(address(market), type(uint256).max);
        tokenB.transferWithCallback(address(market), 250 ether, abi.encode(uint256(1)));
        vm.stopPrank();

        assertEq(tokenB.balanceOf(BOB), 800 ether);
        assertEq(tokenB.balanceOf(ALICE), 1_200 ether);
        assertZeroBalances();
    }

    function testBuyWithCallbackFails() public {
        vm.startPrank(ALICE);
        collection.approve(address(market), 1);
        market.list(1, tokenA, 200 ether);
        vm.stopPrank();

        vm.prank(BOB);
        tokenB.approve(address(market), type(uint256).max);

        vm.prank(BOB);
        vm.expectRevert("NFTMarket: unsupported token");
        tokenB.transferWithCallback(address(market), 200 ether, abi.encode(uint256(1)));

        vm.prank(BOB);
        tokenA.approve(address(market), type(uint256).max);
        vm.prank(BOB);
        vm.expectRevert("NFTMarket: insufficient payment");
        tokenA.transferWithCallback(address(market), 150 ether, abi.encode(uint256(1)));
    }

    function testFuzzListingAndBuying(uint256 price, address buyer) public {
        price = bound(price, 0.01 ether, 10_000 ether);
        vm.assume(buyer != address(0));
        vm.assume(buyer != ALICE);
        vm.assume(buyer.code.length == 0);

        vm.startPrank(ALICE);
        collection.approve(address(market), 2);
        market.list(2, tokenA, price);
        vm.stopPrank();

        deal(address(tokenA), buyer, price);

        vm.startPrank(buyer);
        tokenA.approve(address(market), price);
        vm.expectEmit(true, true, true, true);
        emit Purchase(buyer, ALICE, 2, address(tokenA), price, price);
        market.buyNFT(2);
        vm.stopPrank();

        assertEq(collection.ownerOf(2), buyer);
        assertZeroBalances();
    }

    function assertZeroBalances() internal {
        assertEq(tokenA.balanceOf(address(market)), 0, "tokenA balance non-zero");
        assertEq(tokenB.balanceOf(address(market)), 0, "tokenB balance non-zero");
    }
}
