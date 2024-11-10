// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// gas used => 34422 
contract SolidityFunctionCall {
    function set(address addr, uint256 num) external {
        require(addr != address(0));
        Callme(addr).setNum(num);
    }
}

/// gas used => 34275
contract AssemblyFunctionCall {
    function set(address addr, uint256 num) external {
        assembly {
            // must use hex"cd16ecbf"
            mstore(0x00, hex"cd16ecbf")
            mstore(0x04, num)

            if iszero(extcodesize(addr)) {
                revert(0x00, 0x00) // revert if address has no code deployed to it
            }

            let success := call(gas(), addr, 0x00, 0x00, 0x24, 0x00, 0x00)

            if iszero(success) {
                revert(0x00, 0x00)
            }
        }
    }
}

contract Callme {
    uint256 num = 1;

    function setNum(uint256 a) external {
        num = a;
    }
}
