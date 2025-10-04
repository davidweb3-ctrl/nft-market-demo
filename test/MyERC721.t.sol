// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MyERC721} from "../src/MyERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721Test is Test {
    MyERC721 internal nft;
    address internal constant ALICE = address(0xA11CE);

    function setUp() public {
        nft = new MyERC721();
    }

    function testMint() public {
        string memory uri = "ipfs://QmTokenMetadata";

        uint256 tokenId = nft.mint(ALICE, uri);

        assertEq(tokenId, 1);
        assertEq(nft.ownerOf(1), ALICE);
        assertEq(nft.tokenURI(1), uri);
    }

    function testSequentialMinting() public {
        nft.mint(ALICE, "ipfs://token-1");
        nft.mint(ALICE, "ipfs://token-2");

        assertEq(nft.ownerOf(1), ALICE);
        assertEq(nft.ownerOf(2), ALICE);
        assertEq(nft.tokenURI(2), "ipfs://token-2");
    }

    function test_RevertWhen_NonOwnerMints() public {
        vm.prank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ALICE));
        nft.mint(ALICE, "ipfs://token");
    }
}
