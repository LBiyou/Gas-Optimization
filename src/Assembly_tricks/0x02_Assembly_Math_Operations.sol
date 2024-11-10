// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Assembly_Math_Operation {
    function max(uint256 x, uint256 y) public pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }
}

contract Solidity_Math_Operation {
    function max(uint256 x, uint256 y) public pure returns (uint256 z) {
        z = x > y ? x : y;
    }
}
