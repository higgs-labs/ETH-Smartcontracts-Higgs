---
theme: default
title: "Lesson 4 — Going local with Foundry"
info: |
  In-person Ethereum & Solidity course.
  Lesson 4: leave the browser, set up Foundry, deploy to a local chain.
class: text-center
transition: slide-left
lineNumbers: true
mdc: true
---

# Going local

## Foundry: forge · cast · anvil

Lesson 4 · Ethereum & Solidity for developers

---

# Why leave Remix?

Remix was great for the first taste.

Real projects need:

<v-clicks>

- **Version control** (it's just files)
- **Automated tests** (→ Lesson 6)
- **Repeatable deploys** (→ Lesson 9)
- **Speed** — a local dev loop in seconds

</v-clicks>

---

# Three tools, as concepts first

What is Foundry:

<v-clicks depth="2">

- **`anvil`** — a local Ethereum node. *Your own disposable chain. Fast, free, resets on stop.*
  - Same as in Remix.
- **`forge`** — build & test. *Compiler + test runner + deployer.*
- **`cast`** — the CLI to talk to any chain. *curl for Ethereum.*

</v-clicks>

---

# Project layout

Typically:

```text
counter-project/
├── src/            # contracts
├── lib/            # dependencies
├── test/           # tests
├── script/         # deploy scripts
├── out/            # build artifacts: ABI + bytecode
└── foundry.toml    # config
```

Forge commands know how to look into `out` when you do queries.

---

# Build

Remix' steps, but in Foundry

````md magic-move
```bash
forge init counter-project
```
```bash
forge init counter-project
cd counter-project
```
```bash
forge init counter-project
cd counter-project
# put Counter.sol in src/
```
```bash
forge init counter-project
cd counter-project
# put Counter.sol in src/
forge build
```
````

`forge build` writes the **ABI** and **bytecode** to `out/`.<br/>
The ABI is the interface our front-end will use later. (→ Lesson 10)

<v-clicks at="2">

Take `Counter.sol` from https://pastebin.com/QHhBR39t.
<span class="text-3xl">
QHhBR39t
</span>

The compile step.

</v-clicks>

<!--
In case lost:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
    uint256 public number;          // state, lives on-chain

    function increment() external { // write → transaction → gas
        number += 1;
    }

    function current() external view returns (uint256) {
        return number;              // read → free
    }
}
```
-->

---

# A local chain

````md magic-move
```bash
anvil
```
```bash
anvil
...
Available Accounts
==================

(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
...
(9) 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 (10000.000000000000000000 ETH)

Private Keys
==================

(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
...
```
```bash
...
Wallet
==================
Mnemonic:          test test test test test test test test test test test junk
Derivation path:   m/44'/60'/0'/0/
...
```
```bash
...
Chain ID
==================
31337
...
```
```bash
...
Listening on 127.0.0.1:8545
...
```
```bash
...
export senderAddr=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
export senderPriK=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
```bash
...
export senderAddr=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```
````

<div  v-if="$clicks == 1">

Prints 10 funded dev accounts **and their private keys**.

<div class="mt-6 text-red-500">

These keys are public and well-known. **Local chain only. Never use them on a real network.**

</div>
</div>

<v-clicks at="2">

- We find reference to the *brain wallet*.
- Chain id: `31337`. `1` is mainnet, Sepolia testnet is `11155111`
- Listening on `127.0.0.1:8545` (well-known ethereum node port)
- Make variables with values
- Note the cHeCkSuM.
- With the running simplified chain, what to do?

</v-clicks>

<!-- 
- [click:3] Make students guess the chain id meaning.
-->

---

# Compile & deploy

```` md magic-move
```bash
forge create src/Counter.sol:Counter \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $senderPriK --broadcast
```
```bash
forge create src/Counter.sol:Counter \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $senderPriK --broadcast

Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0x7d991e415f0ba3edf539553f09bc39398fc0401d9f0ec1655641f9c683798e8d
```
```bash
forge create src/Counter.sol:Counter \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $senderPriK --broadcast
export counterInstance=0x5FbDB2315678afecb367f032d93F642f64180aa3      # for reuse
export deployTxHash=0x7d991e415f0ba3edf539553f09bc39398fc0401d9f0ec1655641f9c683798e8d
```
````

- Command:
  - `Counter.sol:Counter` because 1 file may contain more than 1 smart contract definition.
  - A private key in the CLI 🙅‍♂️. That will do for now. 😬

<v-clicks at="1">

- Result:
  - Compiled code, created tx, signed tx, sent tx.
  - You have the same values, do you know why?
  - `forge` has a report, `anvil` has a similar report.
- Again save into variables.
- Let's poke around.

</v-clicks>

<!--
- [click:3] Poke around to get an idea of what happened.
-->

---

# About the deployed code

````md magic-move
```bash
cast code $counterInstance --rpc-url http://127.0.0.1:8545
```
```bash
cast code $counterInstance --rpc-url http://127.0.0.1:8545

0x608060405234801561000f575f5ffd5b5060043610610...
```
````

- It's an expensive read operation.

---

# Observe the new block

```` md magic-move
```bash
cast block --rpc-url http://127.0.0.1:8545
```
```bash
cast block --rpc-url http://127.0.0.1:8545

baseFeePerGas        1000000000
gasLimit             30000000
gasUsed              156813
hash                 0x3a9360ef0d6e30db692f50842dd6d6d9389fb1da0bb71df890679780762d3966
number               1
transactions:        [
        0x7d991e415f0ba3edf539553f09bc39398fc0401d9f0ec1655641f9c683798e8d
]
```
````

<v-clicks at="1">

- Applies to all transactions in the block.
- You don't have the same value. Do you know why?
- Note the *roots*, which are Merkle roots.

</v-clicks>

<!--
- Parameterising can be useful to test what happens when 2 transactions are in the same block.
- We can see that putting the private key in the CLI is not good, so there are improvements to be made here.
- GasUsed is for all transactions.
- Different values because timestamp at least.
-->

---

# Recall the validated transaction

````md magic-move
```bash
cast tx $deployTxHash --rpc-url http://127.0.0.1:8545
```
```bash
cast tx $deployTxHash --rpc-url http://127.0.0.1:8545

blockNumber          1
effectiveGasPrice    1000000001
from                 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
gasLimit             156813
maxFeePerGas         2000000001
maxPriorityFeePerGas 1
to                   
input                0x6080604052348015600e575f5ffd5b5....
```
````

You can see:

<v-clicks at="1">

- How much gas was **allowed** to be consumed, at what max price → max Eth used.
- `to` is empty → deployment transaction.
- No info about smart contract address. 🤔

</v-clicks>

<!--
- [click] Exact gas calculation not possible.
- [click] Deploy transaction: actually a transaction with code execution. 
- Deploy or not.
- [click] Deployment address is an execution outcome concern.
-->

--- 

# Use the transaction receipt

````md magic-move
```bash
cast receipt $deployTxHash --rpc-url http://127.0.0.1:8545
```
```bash
cast receipt $deployTxHash --rpc-url http://127.0.0.1:8545

blockNumber          1
contractAddress      0x5FbDB2315678afecb367f032d93F642f64180aa3
cumulativeGasUsed    156813
effectiveGasPrice    1000000001
gasUsed              156813
status               1 (success)
transactionIndex     0
type                 2
```
````

You can see:

<v-clicks at="1">

- Deployed address: the receipt is the authority here.
- Effective gas price: $price_{effective} = price_{burned}+price_{priority}$.
- Real $cost_{tx} = gas_{used} * price_{effective}$.
- $gas_{xx}$ is its own unit. $price_{xx}$ is in $\text{wei/gas}$. So $cost_{xx}$ is in $\text{wei}$.
- $1\,\text{Eth} = 10^{18}\,\text{wei}$
- $1,000,000,001 * 156,813 = 156,813,000,156,813\,\text{wei}$ i.e. $0.000,156,8 \ldots \text{Eth}$.

</v-clicks>

<!--
- Notice the repeated number pattern because priority fee is very low.
-->

---

# Confirm the remaining balance

````md magic-move
```bash
cast balance $senderAddr --rpc-url http://127.0.0.1:8545
```
```bash
cast balance $senderAddr --rpc-url http://127.0.0.1:8545

9999999843186999843187
```
````

<div v-click="1">

That's:
- $9,999,999,843,186,999,843,187\,\text{wei}$ <-- Left over
- $0,000,000,156,813,000,156,813\,\text{wei}$ <-- Spent

</div>

---

# Interact with the smart contract

````md magic-move
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545    # read, free
```
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545    # read, free

0
```
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545
cast send $counterInstance "increment()" --private-key $senderPriK --rpc-url ...  # write, tx
```
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545
cast send $counterInstance "increment()" --private-key $senderPriK --rpc-url ...  # write, tx

blockHash            0x7870987db9f95ca9bb08be05c6d4fbf46b2c93fea8b700f01c3e803992eb53f1
blockNumber          2
contractAddress      
cumulativeGasUsed    43482
effectiveGasPrice    876306776
gasUsed              43482
transactionHash      0x3fbfbe28a96a0d896e88256592af6f2c34292fdf9086a5d09da8ec6890d27ef9
```
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545
cast send $counterInstance "increment()" --private-key $senderPriK --rpc-url ...
export incrementTx=0x3fbfbe28a96a0d896e88256592af6f2c34292fdf9086a5d09da8ec6890d27ef9
```
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545
cast send $counterInstance "increment()" --private-key $senderPriK --rpc-url ...
export incrementTx=0x3fbfbe28a96a0d896e88256592af6f2c34292fdf9086a5d09da8ec6890d27ef9
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545
```
```bash
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545
cast send $counterInstance "increment()" --private-key $senderPriK --rpc-url ...
export incrementTx=0x3fbfbe28a96a0d896e88256592af6f2c34292fdf9086a5d09da8ec6890d27ef9
cast call $counterInstance "number()(uint256)" --rpc-url http://127.0.0.1:8545

1
```
````

- `cast call` = read

<v-clicks at="1">

- Note `"number()"` → how to call. `"(uint256)"` → how to decode response.
- `cast send` = write.
  - Same split as Remix's blue/orange.
- Note how it does **not** tell us the eventual counter value.
  - Can be a problem when multiple increment function calls are in 1 block.
- Foreshadow: a library like etherjs lets you create objects to call a smart contract elegantly such as `counterInstance.number()`.
- What is the new value?
- Value at end of block, not after execution of tx. ⚠️

</v-clicks>

<!--
- [click] Remember the selector, created from canonical function signature.
- [click:5] That's value at the end of the block.
-->

---

# Interact at a lower level

````md magic-move
```bash
cast keccak256 "number()"
```
```bash
cast keccak256 "number()"

0x8381f58a023328485d7a0ec2da42839972077aa88952ab325a467cbe88c1f73e
```
```bash
cast calldata "number()(uint256)"

0x8381f58a023328485d7a0ec2da42839972077aa88952ab325a467cbe88c1f73e
```
```bash
cast calldata "number()(uint256)"

0x8381f58a
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545

0x0000000000000000000000000000000000000000000000000000000000000001
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
cast decode-abi "number()(uint256)" 0x0000000000000000000000000000000000000000000000000000000000000001
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
cast decode-abi "number()(uint256)" 0x0000000000000000000000000000000000000000000000000000000000000001

1
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
cast decode-abi "number()(uint256)" 0x0000000000000000000000000000000000000000000000000000000000000001
cast 4byte 0x8381f58a
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
cast decode-abi "number()(uint256)" 0x0000000000000000000000000000000000000000000000000000000000000001
cast 4byte 0x8381f58a

number()
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
cast decode-abi "number()(uint256)" 0x0000000000000000000000000000000000000000000000000000000000000001
cast 4byte 0x8381f58a
cast storage $counterInstance 0
```
```bash
cast calldata "number()(uint256)"
cast call $counterInstance 0x8381f58a --rpc-url http://127.0.0.1:8545
cast decode-abi "number()(uint256)" 0x0000000000000000000000000000000000000000000000000000000000000001
cast 4byte 0x8381f58a
cast storage $counterInstance 0

0x0000000000000000000000000000000000000000000000000000000000000001
```
````

<div v-if="$clicks <= 2">

- The canonical function has a signature.

</div>
<v-clicks at="1" depth="2">

- We find this hashing of function and event elsewhere. In particular with account abstraction.
- We can use a more idiomatic `cast`command for the selector.
- What is being passed: call data. Here it's only the [selector](https://toolio.run/tool/function-selector).
  - Sometimes they are [well-known](https://www.4byte.directory/signatures/?bytes4_signature=0x8381f58a). Return type `(uint 256)` is not part of the selector.
- A `uint256` with all its leading zeroes.
- Decode with its ABI.
  - Only the `"(uint256)"` was used. No contract call.
- `cast` can access an API with well-known selectors → reverse lookup.
- If it is in storage, it is visible by all. There is no *private* storage.

</v-clicks>

<!--
- Note the absence of the output type.
- [click]
-->

---

# How to get the proper counter value

````md magic-move
```bash
cast receipt $incrementTx
```
```bash
cast receipt $incrementTx

blockNumber          2
contractAddress      
cumulativeGasUsed    43482
effectiveGasPrice    876306776
gasUsed              43482
logs                 []
```
```bash
cast receipt $incrementTx

blockNumber          2
contractAddress      
cumulativeGasUsed    43482
effectiveGasPrice    876306776
gasUsed              43482
logs                 []
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"

1
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"

1
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"

1
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"            # latest block == 2
cast call --block 1 $counterInstance "number()(uint256)"  # block 1
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"            # latest block == 2
cast call --block 1 $counterInstance "number()(uint256)"  # block 1

0
```
```bash
cast receipt $incrementTx
cast call $counterInstance "number()(uint256)"            # latest block == 2
cast call --block 1 $counterInstance "number()(uint256)"  # block 1
cast call --block 0 $counterInstance "number()(uint256)"  # block 0
```
```bash
cast call $counterInstance "number()(uint256)"
cast call --block 1 $counterInstance "number()(uint256)"
cast call --block 0 $counterInstance "number()(uint256)"

Error: contract 0x5fbdb2315678afecb367f032d93f642f64180aa3 does not have any code
```
````

- Make sure to collect the value **after** the transaction, not ~~at the end of the block~~.

<v-clicks at="1" depth="2">

- No information about the new counter value.
  - Eventually, we fix this with an event.
- We have to call the contract again. No atomicity with the transaction. Race condition!
- Reminder:
  - The transaction is authoritative, and has to be coded so that it is → use event.
  - The value of counter at a block is the value after all transactions have been executed.
- How about history, at previous block?
  - History is conserved, in archive nodes.
- What if try block `0`?
  - Was not deployed yet.

</v-clicks>

<!--
- [click] Also, getting tx-interstitial value would require replaying up to the point.
- Possible, but complex.
-->

---

# Hands-on

Add event

````md magic-move
```solidity
contract Counter {
    uint256 public number;

    ...

    function increment() public {
        number++;
    }
}
```
```solidity
contract Counter {
    uint256 public number;

    event Incremented(address indexed from, uint256 number);
    ...

    function increment() public {
        number++;
    }
}
```
```solidity
contract Counter {
    uint256 public number;

    event Incremented(address indexed from, uint256 number);
    ...

    function increment() public {
        number++;
        emit Incremented(msg.sender, number);
    }
}
```
````

---

# Redeploy

Code changed

Optional: restart `anvil`.

````md magic-move
```bash
forge create src/Counter.sol:Counter --private-key $senderPriK --broadcast
```
```bash
forge create src/Counter.sol:Counter --private-key $senderPriK --broadcast

[⠊] Compiling...
[⠆] Compiling 1 files with Solc 0.8.37
[⠰] Solc 0.8.37 finished in 253.10ms
Compiler run successful!
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0xe605eb860479cb104caaf7c9e349861b3766813d80e5f8face044c3c7aa20213

```
```bash
forge create src/Counter.sol:Counter --private-key $senderPriK --broadcast
export counterInstance=0x5FbDB2315678afecb367f032d93F642f64180aa3
export deployTxHash=0xe605eb860479cb104caaf7c9e349861b3766813d80e5f8face044c3c7aa20213
```
```bash
forge create src/Counter.sol:Counter --private-key $senderPriK --broadcast
export counterInstance=0x5FbDB2315678afecb367f032d93F642f64180aa3
export deployTxHash=0xe605eb860479cb104caaf7c9e349861b3766813d80e5f8face044c3c7aa20213
cast receipt $deployTxHash
```
```bash
forge create src/Counter.sol:Counter --private-key $senderPriK --broadcast
export counterInstance=0x5FbDB2315678afecb367f032d93F642f64180aa3
export deployTxHash=0xe605eb860479cb104caaf7c9e349861b3766813d80e5f8face044c3c7aa20213
cast receipt $deployTxHash

...
logs                 []
...
```
````

<v-clicks at="1">

- New smart contract deployed.
- Save values.
- New things in receipt?
- No. Why?

</v-clicks>

---

# Increment again

Now with an event

````md magic-move
```bash
cast send $counterInstance "increment()" --private-key $senderPriK
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK

...
logs                 [{
  "address":"0x5fbdb2315678afecb367f032d93f642f64180aa3",
  "topics":["0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420",
    "0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266"
  ],
  "data":"0x0000000000000000000000000000000000000000000000000000000000000001",
  ...
}]
transactionHash      0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
transactionIndex     0
...
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK

...
logs                 [{
  "address":"0x5fbdb2315678afecb367f032d93f642f64180aa3",
  "topics":["0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420",  # <--
    "0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266"           # <--
  ],
  "data":"0x0000000000000000000000000000000000000000000000000000000000000001",     # <--
  ...
}]
transactionHash      0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
transactionIndex     0
...
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK

...
logs                 [{
  "address":"0x5fbdb2315678afecb367f032d93f642f64180aa3",
  "topics":["0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420",
    "0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266"
  ],
  "data":"0x0000000000000000000000000000000000000000000000000000000000000001",
  ...
}]
transactionHash      0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
transactionIndex     0                                                             # <--
...
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK
export incrementTx=0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK
export incrementTx=0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
cast receipt $incrementTx
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK
export incrementTx=0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
cast receipt $incrementTx

...
"topics":["0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420",
...
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK
export incrementTx=0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
cast receipt $incrementTx

...
"topics":["0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420",
...
cast keccak256 "Incremented(address,uint256)"
```
```bash
cast send $counterInstance "increment()" --private-key $senderPriK
export incrementTx=0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc

"topics":["0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420",
cast keccak256 "Incremented(address,uint256)"

0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420
```
````

<v-clicks at="1" depth="2">

- Now `logs` has 1 object in array:
  - 2 topics, 1 data. `indexed` sends into `topics`.
  - Note: `transactionIndex`. In block.
- Save tx hash.
- Confirm that this log is in the tx receipt.
- Same things
- The first topic is from the canonical event signature. Convention.
- Same again.

</v-clicks>

---

# A look at the logs

Independently

````md magic-move
```bash
cast logs "Incremented(address indexed from, uint256 number)"
```
```bash
cast logs "Incremented(address indexed from, uint256 number)"

- address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  blockHash: 0x53f772b96491a0d9513c913de66db5cd73612dcbc15ddca795d7fa8b45814555
  blockNumber: 2
  data: 0x0000000000000000000000000000000000000000000000000000000000000001
  logIndex: 0
  removed: false
  topics: [
        0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420
        0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
  ]
  transactionHash: 0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
  transactionIndex: 0
```
```bash
cast logs "Incremented(address indexed from, uint256 number)"

- address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  blockHash: 0x53f772b96491a0d9513c913de66db5cd73612dcbc15ddca795d7fa8b45814555
  blockNumber: 2
  data: 0x0000000000000000000000000000000000000000000000000000000000000001
  logIndex: 0                                                                        # <--
  removed: false
  topics: [
        0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420
        0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
  ]
  transactionHash: 0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
  transactionIndex: 0
  decoded:
  	from: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
  	number: 1
```
```bash
cast logs "Incremented(address indexed from, uint256 number)"

- address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  blockHash: 0x53f772b96491a0d9513c913de66db5cd73612dcbc15ddca795d7fa8b45814555
  blockNumber: 2                                                                     # A
  data: 0x0000000000000000000000000000000000000000000000000000000000000001
  logIndex: 0                                                                        # C
  removed: false
  topics: [
        0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420
        0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
  ]
  transactionHash: 0xf28203ec9f7baea20443c552246a2258e298088d59135c2b716b9e7ed3206edc
  transactionIndex: 0                                                                # B
  decoded:
  	from: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
  	number: 1
```
````

- Extract per type. Any smart contract address.

<v-clicks at="1" depth="2">

- Looks similar
- With the addition of `logIndex`. Position in tx logs.
- `blockNumber / transactionIndex / logIndex`: absolute order of logs.

</v-clicks>

---
layout: center
---

## Take-home

From an **empty folder**, reproduce it all from memory:

`forge init` → `forge build` → `anvil` → deploy → `increment`

If a step breaks, **write down which one**. We want to know.
