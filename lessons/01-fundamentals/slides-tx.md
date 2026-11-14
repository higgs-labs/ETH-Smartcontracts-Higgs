---
layout: section
---

# Interlude — what *is* a transaction?

The unit of change on the ledger

---

# An Ethereum transaction

How it looks at a low level: [example](https://etherscan.io/tx/0x3eed2ba3a1783a437f77731d0657e31505d5447b0abdb268d28a9b4b70dfdea2):

<v-clicks>

- A series of bytes: [example](https://etherscan.io/getRawTx?tx=0x3eed2ba3a1783a437f77731d0657e31505d5447b0abdb268d28a9b4b70dfdea2).
  <span v-if="$clicks==1"><br/>
  ```
  0x02f902130183013d798394eb3784036076448303876f94173272739bd7aa6e4e214714048a9fe69945305980b901a4cfc3257000000000000000000000000000000000000000000000000000000000000000200000000000000000000000006c96de32cea08842dcc4058c14d3aaad7fa41dee00000000000000000000000000000000000000000000000000000000000076b60000000000000000000000009151434b16b9763660705744891fa906f660ecc5000000000000000000000000000000000000000000000000000000000000069f461beee85c851869e2a03b0bc051be5b0edf5a4b7949bb864c0dbbffab41aaa30000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000187ad000000000000000000000000000000000000000000000000000000000000002800000000000000000000000007ae8551be970cb1cca11dd7a11f47ae82e70e67000000044c48ab610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c080a0b786c19ef1a7f786e98d1f1551723c8d5ad5a3f2619f2ed6ee5aed6ca8df90c4a06146722b585744567c239bd7b9c2f2a3c4a788601cedacc330927619d59c9f61
  ```
  </span>
- RLP-decoded (see later) [example](https://vayce.app/tools/binary-format-decoder/rlp-decoder)
  <span v-if="$clicks==2"><br/>
  ```
  [
  "<0x01 = 1>",   // chainId
  "<0x013d79 = 81273>", // nonce
  "<0x94eb37 = 9759543>", // maxPriorityFeePerGas
  "<0x03607644 = 56653380>", // maxFeePerGas
  "<0x03876f = 231279>", // gasLimit
  "<bytes 173272739bd7aa6e4e214714048a9fe699453059>", // to
  "<empty>", //value
  "<bytes cfc3257000000000000000000000000000000000000000000000000000000000000000200000000000000000000000006c96de32cea08842dcc4058c14d3aaad7fa41dee00000000000000000000000000000000000000000000000000000000000076b60000000000000000000000009151434b16b9763660705744891fa906f660ecc5000000000000000000000000000000000000000000000000000000000000069f461beee85c851869e2a03b0bc051be5b0edf5a4b7949bb864c0dbbffab41aaa30000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000187ad000000000000000000000000000000000000000000000000000000000000002800000000000000000000000007ae8551be970cb1cca11dd7a11f47ae82e70e67000000044c48ab610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000>", // data
  [], // accessList
  "<empty>", // yParity
  "<bytes b786c19ef1a7f786e98d1f1551723c8d5ad5a3f2619f2ed6ee5aed6ca8df90c4>", // r
  "<bytes 6146722b585744567c239bd7b9c2f2a3c4a788601cedacc330927619d59c9f61>" // s
  ]
  ```
  Manually annotated. 3 signature fields at the bottom.
  <br/>Reflects Etherscan view. Extra fields because _in block_.
  </span>
- A hash of the bytes: [example](https://emn178.github.io/online-tools/keccak_256.html)
  <span v-if="$clicks==3"><br/>Set _Hex input encoding_, remove `0x` from bytes.
  ```
  0x3eed2ba3a1783a437f77731d0657e31505d5447b0abdb268d28a9b4b70dfdea2
  ```
  </span>
- RLP-encoded minus signature: [example](https://toolkit.abdk.consulting/ethereum#rlp)
  <span v-if="$clicks==4"><br/>
  ```
  0x02f901d00183013d798394eb3784036076448303876f94173272739bd7aa6e4e214714048a9fe69945305980b901a4cfc3257000000000000000000000000000000000000000000000000000000000000000200000000000000000000000006c96de32cea08842dcc4058c14d3aaad7fa41dee00000000000000000000000000000000000000000000000000000000000076b60000000000000000000000009151434b16b9763660705744891fa906f660ecc5000000000000000000000000000000000000000000000000000000000000069f461beee85c851869e2a03b0bc051be5b0edf5a4b7949bb864c0dbbffab41aaa30000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000187ad000000000000000000000000000000000000000000000000000000000000002800000000000000000000000007ae8551be970cb1cca11dd7a11f47ae82e70e67000000044c48ab610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0
  ```
  </span>
- Hash that for signature:
  <span v-if="$clicks==5"><br/>Set _Hex input encoding_, remove `0x` from bytes.
  ```
  0x3fcf81331059f2f8df9af87937c105fcca97c210c0fc6329a32e4240fcfe76c0
  ```
  </span>

</v-clicks>

<!--
- Show Etherscan fields, quick explanation.
- Etherscan decoded for us. See the raw.
- [click] That's 1 big byte array.
- That's what gets passed around the network.
- [click] That's encoded with special technique.
- But fields are there.
- [click] The hash that Etherscan knows contains the signature, as it uses content addressing.
- Not doing so, would risk losing the signatures.
- But if the hash contains signatures, then that is not the hash that was used for signing.
- [click] Remove signatures to get the hash to sign.
-->

---

# The one-sentence definition

A transaction is an **atomic event, authorised by a signature, that the protocol allows to change the shared state**.

<v-clicks>

- **Atomic** — it either happens completely or not at all. There is no half-applied transaction.
- **Authorised** — it carries a signature, typically from the sender's private key (section 3). No valid signature, no transaction.
- **State-changing** — it updates the global state that *every* node replicates, not one row on one machine.

</v-clicks>
<div v-click="4">

> In SQL db, a tx updates 1 table on 1 server.
> <br/>In blockchain, it updates the same state across the whole network.
> <br/>Or rather, all nodes that accept the transaction as valid, apply it deterministically.
> <br/>Many nodes end up with the same output state, on which they can reach consensus.

</div>
<v-clicks at="5" depth="2">

- For a cryptographic signature mechanism, a tx is a hashable byte array.
- A block: many tx: [example](https://etherscan.io/block/26270132)
  - How to assemble many signatures together? Efficiently? Provably? Deterministic [sequence](https://etherscan.io/txs?block=26270132)?

</v-clicks>
