// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Callme, SolidityFunctionCall, AssemblyFunctionCall} from "../../src/Assembly_tricks/0x01_FunctionCall_Assembly.sol";
import {Test} from "forge-std/Test.sol";

contract FunctionCall_Assembly_Solidity_Test is Test {
    address owner = makeAddr("owner");
    SolidityFunctionCall sfc;
    AssemblyFunctionCall afc;
    Callme callme;

    function setUp() external {
        vm.startPrank(owner);
        sfc = new SolidityFunctionCall();
        afc = new AssemblyFunctionCall();
        callme = new Callme();
        vm.stopPrank();
    }

    function testSolidityFunctionCall() external {
        uint256 totalUsed;
        for (uint256 i = 0; i < 100; i++) {
            uint256 gasBefore = gasleft();
            sfc.set(address(callme), i);
            totalUsed += gasBefore - gasleft();
        }
        emit log_named_uint(
            "Average Gas Used With SolidityFunctionCall =>",
            totalUsed / 100
        );
    }

    function testAssemblyFunctionCall() external {
        uint256 totalUsed;
        for (uint256 i = 0; i < 100; i++) {
            uint256 gasBefore = gasleft();
            afc.set(address(callme), i);
            totalUsed += gasBefore - gasleft();
        }
        emit log_named_uint(
            "Average Gas Used With AssemblyFunctionCall =>",
            totalUsed / 100
        );
    }
}
