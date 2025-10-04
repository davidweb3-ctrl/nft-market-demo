// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract MyERC20Script is Script {
    uint256 internal constant INITIAL_SUPPLY = 1_000_000 ether;

    function run() public returns (MyERC20 deployed) {
        vm.startBroadcast();
        deployed = new MyERC20();
        vm.stopBroadcast();
    }
}
