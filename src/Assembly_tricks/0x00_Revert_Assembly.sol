// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// calling restrictedAction(2) with a non-owner address: 23641
contract SolidityRevert {
    address owner;
    uint256 specialNumber;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    function restrictedAction(uint256 num) external onlyOwner {
        specialNumber = num;
    }
}

/// calling restrictedAction(2) with a non-owner address: 23549
contract AssemblyRevert {
    address owner;
    uint256 specialNumber;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        assembly {
            if sub(caller(), sload(owner.slot)) {
                // case1:
                // mstore(0x00, 0x63616c6c6572206973206e6f74206f776e657200000000000000000000000000)
                // revert(0x00, 0x19)

                // case2:
                // origin => abi.encode("caller is not owner")
                mstore(0x00, 0x20) // store offset to where length of revert message is stored
                mstore(0x20, 0x13) // store length (19)
                mstore(
                    0x40,
                    0x63616c6c6572206973206e6f74206f776e657200000000000000000000000000
                ) // store hex representation of message
                revert(0x00, 0x60) // revert with data
            }
        }
        _;
    }

    function restrictedAction(uint256 num) external onlyOwner {
        specialNumber = num;
    }
}
