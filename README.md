### 前言

> **Gas 是在以太坊网络上执行特定操作所需的计算量计量单位，而 Solidity Gas 优化是降低 Solidity 智能代码执行成本的过程。** 
>
> **作为一个智能合约开发工程师或是智能合约安全研究员，熟悉Gas优化是必备的技能之一。**
>
> **参考资料：**
>
> - [Link1](https://www.cyfrin.io/blog/solidity-gas-optimization-tips#11-extra-solidity-gas-optimization-tip-use-assembly)
> - [Link2](https://www.rareskills.io/post/gas-optimization#viewer-dfkcg)

### Assembly Tricks

尽管汇编语言的可读性较差编写起来也十分麻烦，但是在`Gas 优化`上却有独特的优势，这就需要权衡利弊了。下面介绍几种常用的技巧。

**案例在remix中测试更为准确。**

#### 0x00 Revert Assembly

> 在 solidity 代码中恢复时，通常使用 require 或 revert 语句来恢复执行并显示错误消息。在大多数情况下，可以使用 assembly 来进一步优化，以显示错误消息。
>
> 在某些需要频繁验证的操作中，可以适当引用汇编语言。

**case：**

```solidity
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
```

*大约节省`100`。*

**使用汇编语言来进行验证时，不管操作是否被``revert()`，gas费用都会降低。如果操作被`revert()`则可以节省更多的gas。**

**从上面的例子中可以看出，使用 assembly 恢复相同的错误消息比使用 solidity 恢复时节省了大约 100 gas。节省的 gas 来自内存扩展成本和 solidity 编译器在后台执行的额外类型检查。**



#### 0x01 Assembly Function Call

> 当从另一个合约 A 调用合约 B 上的函数时，最方便的方式是使用接口，使用地址创建 B 的实例，然后调用我们希望调用的函数。这种方法效果很好，但由于 solidity 编译代码的方式，它会将要发送给合约 B 的数据存储在新的内存位置，从而扩展内存，有时这是不必要的。使用内联汇编，我们可以更好地优化代码，并使用以前不再需要的内存位置或（如果合约 B 预期的调用数据小于 64 字节）在临时空间中存储调用数据来节省一些 gas。

```solidity
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

```

*节省`148` gas。*

**在 Assembly 上调用 `set(uint256)` 比使用 solidity 少花费 148 gas。请注意，当使用内联汇编进行外部调用时，重要的是使用 extcodesize(addr) 检查我们调用的地址是否部署了代码，如果返回 0，则还原。这很重要，因为调用没有部署代码的地址总是返回 true，这在大多数情况下对我们的合约逻辑可能是毁灭性的。**

#### 0x02 Assembly Math Operations

> 对于一些数学操作，使用汇编语言编写的数学库可以在一定程度上可以节省`gas`费。
>
> 数学工具包：[FixedPointMathLib](https://github.com/Vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol).

**case:**

````solidity
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

````

**result:**

```js
Ran 2 tests for test/Assembly_tricks/0x02_Assembly_tricks_Test.t.sol:Assembly_Math_Operation_Test  
[PASS] test_Assembly_Math_Operation() (gas: 5498)
[PASS] test_Solidity_Math_Operation() (gas: 5513)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 652.00µs (240.10µs CPU time)
```

**上面的例子更节省气体的原因是三元运算符（一般来说，带有条件的代码）在操作码中包含条件跳转，这更昂贵。**

#### 0x03 Assembly SUB Instead Of ISZERO

> 当使用内联汇编比较两个值是否相等时（例如，如果所有者与调用者（）相同），有时这样做更有效。

**case:**

```solidity
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

```

**xor 可以完成同样的事情，但请注意 xor 会将所有位翻转的值视为相等，因此请确保这不能成为攻击媒介。这个技巧将取决于所使用的编译器版本和代码的上下文。**

#### 0x04 Assembly Check Zero Address

> 使用内联汇编进行零地址校验，更省gas。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract NormalAddressZeroCheck {
    function check(address _caller) public pure returns (bool) {
        require(_caller != address(0x00), "Zero address");
        return true;
    }
}

contract AddressZeroCheckAssembly {
    // Saves about 50 gas
    function checkOptimized(address _caller) public pure returns (bool) {
        assembly {
            if iszero(_caller) {
                mstore(0x00, 0x20)
                mstore(0x20, 0x0c)
                mstore(0x40, 0x5a65726f20416464726573730000000000000000000000000000000000000000) // load hex of "Zero Address" to memory
                revert(0x00, 0x60)
            }
        }
        return true;
    }
}
```



