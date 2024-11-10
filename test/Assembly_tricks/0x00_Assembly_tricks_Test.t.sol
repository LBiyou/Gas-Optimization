// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SolidityRevert, AssemblyRevert} from "../../src/Assembly_tricks/0x00_Revert_Assembly.sol";
import {Test} from "forge-std/Test.sol";

contract SolidityRevert_AssemblyRevert_Test is Test {
    address owner = makeAddr("owner");
    SolidityRevert sr;
    AssemblyRevert ar;

    function setUp() external {
        vm.startPrank(owner);
        sr = new SolidityRevert();
        ar = new AssemblyRevert();
        vm.stopPrank();
    }

    function testFailSolidityRevert() external  {
        sr.restrictedAction(2);
    }

    function testFailAssemblyRevert() external  {
        ar.restrictedAction(2);
    }
}
