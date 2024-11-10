// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Assembly_Verify {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function assemblyVerify() external view {
        assembly {
            if sub(caller(), sload(owner.slot)) {
                revert(0, 0)
            }
        }
    }

    function solidityVerify() external view {
        assembly {
            if eq(caller(), sload(owner.slot)) {
                revert(0, 0)
            }
        }
    }
}
