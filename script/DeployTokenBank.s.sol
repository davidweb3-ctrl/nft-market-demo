// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {TokenBank} from "../src/TokenBank.sol";

contract DeployTokenBank is Script {
    function run() external returns (MyERC20 token, TokenBank bank) {
        vm.startBroadcast();
        token = new MyERC20();
        bank = new TokenBank(token);
        vm.stopBroadcast();

        console2.log("MyERC20 deployed at:", address(token));
        console2.log("TokenBank deployed at:", address(bank));
    }
}
