// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract MyERC20Test is Test {
    MyERC20 internal token;
    address internal constant ALICE = address(0xA11CE);
    address internal constant BOB = address(0xB0B);
    uint256 internal constant INITIAL_SUPPLY = 100_000_000 * 1e18;

    function setUp() public {
        token = new MyERC20();
    }

    function testInitialSupplyAssignedToDeployer() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY);
        assertEq(token.decimals(), 18);
        assertEq(token.name(), "BaseERC20");
        assertEq(token.symbol(), "BERC20");
    }

    function testTransfer() public {
        token.transfer(ALICE, 100 ether);
        assertEq(token.balanceOf(ALICE), 100 ether);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY - 100 ether);
    }

    function testTransferFrom() public {
        token.approve(ALICE, 200 ether);

        vm.prank(ALICE);
        token.transferFrom(address(this), BOB, 200 ether);

        assertEq(token.balanceOf(BOB), 200 ether);
        assertEq(token.allowance(address(this), ALICE), 0);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY - 200 ether);
    }

    function test_RevertWhen_TransferInsufficientBalance() public {
        vm.prank(ALICE);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(BOB, 1);
    }

    function test_RevertWhen_TransferFromWithoutApproval() public {
        vm.prank(ALICE);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        token.transferFrom(address(this), BOB, 1);
    }

    function test_RevertWhen_TransferFromInsufficientBalance() public {
        token.transfer(ALICE, 100 ether);
        vm.prank(ALICE);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transferFrom(ALICE, BOB, 200 ether);
    }
}
