// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public currentConfig;

    constructor() {
        if (block.chainid == 11155111) {
            currentConfig = getSepoliaEthConfig();
        } else {
            currentConfig = getAnvillEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkConfig memory config)
    {
        config = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getAnvillEthConfig() public returns (NetworkConfig memory config) {
        vm.startBroadcast();
        MockV3Aggregator aggregator = new MockV3Aggregator(
            18,
            2000000000000000000
        );

        config = NetworkConfig({priceFeed: address(aggregator)});
        vm.stopBroadcast();
    }
}
