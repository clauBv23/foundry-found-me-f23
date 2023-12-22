// SPDT-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeDeployment} from "../script/FundMeDeployment.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        FundMeDeployment deployment = new FundMeDeployment();
        fundMe = deployment.run();
        vm.deal(USER, STARTING_BALANCE);
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

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testFundAddsFunderToArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getFunder(0), USER);
    }

    modifier fund(address user) {
        vm.prank(user);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public fund(USER) {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public fund(USER) {
        address owner = fundMe.getOwner();

        // arrange
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialFundMeBalance = address(fundMe).balance;
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);

        //act
        vm.prank(owner);
        fundMe.withdraw();

        // assert
        assertEq(fundMe.getAddressToAmountFunded(USER), 0);

        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + initialFundMeBalance);
    }

    function testWithdrawWithMultipleFunders() public {
        address owner = fundMe.getOwner();

        // arrange
        _fundXAddresses(10);
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(owner);
        fundMe.withdraw();

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + initialFundMeBalance);
    }

    function testCheaperWithdrawWithSingleFunder() public fund(USER) {
        address owner = fundMe.getOwner();

        // arrange
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialFundMeBalance = address(fundMe).balance;
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);

        //act
        vm.prank(owner);
        fundMe.cheaperWithdraw();

        // assert
        assertEq(fundMe.getAddressToAmountFunded(USER), 0);

        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + initialFundMeBalance);
    }

    function testCheaperWithdrawWithMultipleFunders() public {
        address owner = fundMe.getOwner();

        // arrange
        _fundXAddresses(10);
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(owner);
        fundMe.cheaperWithdraw();

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + initialFundMeBalance);
    }

    // helpers
    function _fundXAddresses(uint160 _x) internal {
        for (uint160 i = 1; i <= _x; ++i) {
            // prank and deel on the same operation
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
    }
}
