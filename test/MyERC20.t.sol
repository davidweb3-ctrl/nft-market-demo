// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MyERC20, IERC20TokenReceiver} from "../src/MyERC20.sol";

contract MyERC20Test is Test {
    MyERC20 internal token;
    address internal constant ALICE = address(0xA11CE);
    address internal constant BOB = address(0xB0B);
    uint256 internal constant INITIAL_SUPPLY = 100_000_000 * 1e18;

    DummyReceiver internal receiver;

    function setUp() public {
        token = new MyERC20();
        receiver = new DummyReceiver();
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

    function testTransferWithCallbackToEOA() public {
        bytes memory callbackData = abi.encode("hello");
        token.transferWithCallback(ALICE, 100 ether, callbackData);

        assertEq(token.balanceOf(ALICE), 100 ether);
    }

    function testTransferWithCallbackToContract() public {
        bytes memory callbackData = abi.encode(uint256(42));
        token.transferWithCallback(address(receiver), 50 ether, callbackData);

        assertEq(token.balanceOf(address(receiver)), 50 ether);
        assertEq(receiver.lastFrom(), address(this));
        assertEq(receiver.lastAmount(), 50 ether);
        assertEq(receiver.lastData(), callbackData);
    }

    function test_RevertWhen_CallbackContractFails() public {
        FailingReceiver badReceiver = new FailingReceiver();

        vm.expectRevert("ERC20: tokensReceived failed");
        token.transferWithCallback(address(badReceiver), 1 ether, "");
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

contract DummyReceiver is IERC20TokenReceiver {
    address private _lastFrom;
    uint256 private _lastAmount;
    bytes private _lastData;

    function tokensReceived(address from, uint256 amount, bytes calldata data) external override {
        _lastFrom = from;
        _lastAmount = amount;
        _lastData = data;
    }

    function lastFrom() external view returns (address) {
        return _lastFrom;
    }

    function lastAmount() external view returns (uint256) {
        return _lastAmount;
    }

    function lastData() external view returns (bytes memory) {
        return _lastData;
    }
}

contract FailingReceiver is IERC20TokenReceiver {
    function tokensReceived(address, uint256, bytes calldata) external pure override {
        revert("onTokensReceived failed");
    }
}
