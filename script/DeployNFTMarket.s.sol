// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {MyERC721} from "../src/MyERC721.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract DeployNFTMarket is Script {
    function run() external returns (MyERC721 collection, NFTMarket market) {
        vm.startBroadcast();
        collection = new MyERC721();
        market = new NFTMarket(collection);
        vm.stopBroadcast();

        console2.log("MyERC721 deployed at:", address(collection));
        console2.log("NFTMarket deployed at:", address(market));
    }
}
