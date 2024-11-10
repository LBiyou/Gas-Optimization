// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Assembly_Verify} from "../../src/Assembly_tricks/0x03_SUB_Instead_ISZERO.sol";
import {Test} from "forge-std/Test.sol";

contract Assembly_Verify_Test is Test {
    Assembly_Verify assembly_verify;
    address user = makeAddr("user");
    address deployer = makeAddr("deployer");

    function setUp() external {
        vm.startPrank(deployer);
        assembly_verify = new Assembly_Verify();
        vm.stopPrank();
    }

    function testFailAssemblyVerify() external  {
        vm.prank(user);
        assembly_verify.assemblyVerify();
    }

    function testFailSolidityVerify() external  {
        vm.prank(deployer);
        assembly_verify.solidityVerify();
    }
}