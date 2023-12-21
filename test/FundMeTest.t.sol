// SPDT-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeDeployment} from "../script/FundMeDeployment.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    FundMeDeployment deployment;

    function setUp() external {
        deployment = new FundMeDeployment();
        fundMe = deployment.run();
    }

    function testMinimumDolarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }
}
