// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public currentConfig;

    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    uint256 public constant SEPOLIA_CHAINID = 11155111;

    constructor() {
        if (block.chainid == SEPOLIA_CHAINID) {
            currentConfig = getSepoliaEthConfig();
        } else {
            currentConfig = getOrCreateAnvillEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory config) {
        config = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getOrCreateAnvillEthConfig() public returns (NetworkConfig memory config) {
        if (currentConfig.priceFeed != address(0)) {
            return currentConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator aggregator = new MockV3Aggregator(ETH_DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        config = NetworkConfig({priceFeed: address(aggregator)});
    }
}
