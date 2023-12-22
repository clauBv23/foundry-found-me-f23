// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 private constant SEND_VALUE = 0.1 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }

    function fundFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(fundMeAddress);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded with %s", SEND_VALUE);
    }
}

contract WithdrawFundMe is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }

    function withdrawFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(fundMeAddress);
        fundMe.withdraw();
        vm.stopBroadcast();

        console.log("Withdraw FundMe balance");
    }
}
