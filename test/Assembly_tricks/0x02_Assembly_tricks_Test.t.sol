// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Assembly_Math_Operation, Solidity_Math_Operation} from "../../src/Assembly_tricks/0x02_Assembly_Math_Operations.sol";
import {Test} from "forge-std/Test.sol";

contract Assembly_Math_Operation_Test is Test {
    Assembly_Math_Operation assembly_math_operation;
    Solidity_Math_Operation solidity_math_operation;

    function setUp() external {
        assembly_math_operation = new Assembly_Math_Operation();
        solidity_math_operation = new Solidity_Math_Operation();
    }

    function test_Assembly_Math_Operation() external view {
        assembly_math_operation.max(1, 2);
    }

    function test_Solidity_Math_Operation() external view {
        solidity_math_operation.max(1, 2);
    }
}