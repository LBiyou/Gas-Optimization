// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NormalAddressZeroCheck, AddressZeroCheckAssembly} from "../../src/Assembly_tricks/0x04_Assembly_Check_Zero_Address.sol";
import {Test} from "forge-std/Test.sol";

contract Assembly_Check_Zero_Address_Test is Test {
    NormalAddressZeroCheck normalAddressZeroCheck;
    AddressZeroCheckAssembly addressZeroCheckAssembly;
    address user = makeAddr("user");
    address deployer = makeAddr("deployer");

    function setUp() external {
        vm.startPrank(deployer);
        normalAddressZeroCheck = new NormalAddressZeroCheck();
        addressZeroCheckAssembly = new AddressZeroCheckAssembly();
    }

    function testNormalAddressZeroCheck() external view {
        normalAddressZeroCheck.check(user);
    }

    function testAssemblyAddressZeroCheck() external view {
        addressZeroCheckAssembly.checkOptimized(deployer);
    }
}
