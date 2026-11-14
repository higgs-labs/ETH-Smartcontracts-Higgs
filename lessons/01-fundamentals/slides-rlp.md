---
layout: section
---

# 5. RLP encoding

Turning structured data into deterministic byte arrays

<!--
- We saw an unexplained example when looking at the transaction example.
-->

---

# Why yet another encoding?

Performance, determinism

<v-clicks depth="2">

- Hashes, signatures: 1 bit change → invalid. Need determinism.
- **Determinism** on **structured** object. Numbers, byte strings, nested fields, lists.
  - JSON? lol.
- Serialise single, deterministic (unambiguous) byte string.
- 2 nodes, ≠ specs, ≠ dates, ≠ locations → exact same bytes.
- Ethereum's answer: **RLP** — *Recursive Length Prefix* encoding.
  - No complex data types.

</v-clicks>

<!--
- 
-->

---

# What RLP is (and isn't)

Minimalism is the point: fewer rules means fewer ways for two implementations to disagree.

<v-clicks depth="3">

- Encodes **2** things:
  1. **Byte strings**, i.e. a sequence of bytes. `0x2345`
  1. **Lists**, i.e. items that are themselves: `[??]`
      - Byte strings. `[ 0x2356, 0x3319, ?? ]`
      - Or lists → *recursive*. `[ 0x2356, [ 0x3319, ?? ], 0x9976, ?? ]`
- Data *types*? 🙅‍♂️ ~~booleans~~, ~~integers~~, ~~structs~~.
  - Got a `0x41`? 🤷‍♂️ Higher layers decide → number 65 or ASCII `a`.
- RLP only answers *"where does each item start and end?"*

</v-clicks>

<!--
- [click:3]
- [click] That's it.
- [click] What about length prefix? It's coming.
- [click] To belabour the point, it does not care about some things.
- [click:2] So let's see how it goes.
-->

---

# The encoding rules, briefly

<v-clicks depth="2">

- Each encoded item carries a **length prefix** → how to read what follows:
- 1 **single byte** in `[0x00, 0x7f]` → its own encoding — no prefix.
  - Refresher: `0x7f == 0b_0111_1111` and `0x80 == 0b_1000_0000`.
- A **short** (0–55 bytes) **byte array**: prefix `0x80 + length-of-bytes`, then the bytes.
  - Checking: `0x80 + 55 == 128 + 55 == 183 == 0xb7 == 0b_1011_0111` .
- A **long** (> 55 bytes) **byte array**: prefix `0xb7 + length-of-[length-of-bytes]` `||` `length-of-bytes` `||` `bytes`.
  - Checking: `0xb7 + 9 == 0xc0` so length-of-length can only be 8-byte long.
  - And 8 bytes `length-of-bytes` go up to: `256^8 == 2^64 == 18*10^18` bytes.
  - i.e. max array length is ~18 exabytes.
- **Lists** mirror this with the `0xc0` / `0xf7` prefix ranges, over the concatenated encodings of their items.
  - `0xc0 + 55 == 192 + 55 == 247 == 0xf7`. Whole payload max 55-byte.
  - `0xf7 + 8 == 0xff`. Whole payload >55 bytes.
- Prefix ranges never overlap. Decoder knows reading: byte / string / list.

</v-clicks>

<!--
- [click:2]
- [click] First half is reserved for single bytes.
- [click:2]
- [click] Let's build from the right, bytes, length of bytes, length of length.
- [click] Why `0xc0`? It's the next prefix.
- [click]
- [click] exabytes, hopefully enough for a couple decades.
- [click]
- [click] Whole payload max 55 bytes.
- First item starts immediately.
- Next after 1st item is finished.
- [click] We can imagine parallelisation where payload is passed to sub decoder.
- [click] No need to know by heart.
- Know you can look it up.
-->

---

# Practical example

````md magic-move
```text
"cat"           →       [ 'c', 'a', 't' ]
```
```text
"cat"           → [ 0x??, 'c', 'a', 't' ]
```
```text
"cat"           → [ 0x??, 'c', 'a', 't' ]
    bytes count →          1    2    3
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x??, 'd', 'o', 'g' ]
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x??, 'd', 'o', 'g' ]
    bytes count →          1    2    3
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)

[ "cat", "dog" ] →       [ 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g' ]
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)

[ "cat", "dog" ] → [ 0x??, 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g' ]
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)

[ "cat", "dog" ] → [ 0x??, 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g' ]
    bytes count  →           1    2    3    4      5   6    7    8
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)

[ "cat", "dog" ] → [ 0x??, 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g' ]
    bytes count  →     ↑     1    2    3    4      5   6    7    8 <= 55
                      0x?? = 0xc0 +                             
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)

[ "cat", "dog" ] → [ 0xc8, 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g' ]
    bytes count  →     ↑     1    2    3    4      5   6    7    8 ↴
                      0xc8 = 0xc0 +                             <- 8  (a list whose payload is 8 bytes)
```
```text
"cat"           → [ 0x83, 'c', 'a', 't' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)
"dog"           → [ 0x83, 'd', 'o', 'g' ]
    bytes count →     ↑    1    2    3 ↴
                     0x83 = 0x80 +  <- 3  (a 3-byte string)

[ "cat", "dog" ] → [ 0xc8, 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g' ]
    bytes count  →     ↑     1    2    3    4      5   6    7    8 ↴
                      0xc8 = 0xc0 +                             <- 8  (a list whose payload is 8 bytes)

""  (empty string) → [ 0x80 ]
[]  (empty list)   → [ 0xc0 ]
```
````

<v-clicks>

- Notation: $RLP("cat")$, $RLP\Big(["cat", "dog"]\Big)$.
- Notice: `"cat"` & `"dog"` encoded first. Then wrapped in list.
- Nesting, → *recursive* in RLP.

</v-clicks>

<!--
- We are encoding cat.
- What do we need to do?
- [click] We need a prefix.
- But which one? It's an array of bytes.
- [click] So we count the bytes.
- [click] Which we add to the byte array prefix root.
- [click] Moving to next word.
- [click:2]
- [click] Now we make a list.
- What do we need to do?
- [click] We need a prefix.
- But which one? It's a list.
- [click] So we count the bytes.
- [click] It's a *small* list -> `0xc0`.
- [click] To which we add to the list size.
- And you notice we can start from left and extract as we go.
- [click] Extra edge cases.
-->

---

# Cool, where does RLP show up?

<v-clicks depth="3">

- **Transactions** — Ethereum tx are RLP-encoded, then hashed and signed. On Etherscan: you see $keccak_{256}\Big(RLP(tx_{signed})\Big)$.
  - Type 0 (legacy): $tx_{signed}=[nonce, gasPrice, gasLimit, to, value, data, v, r, s]$
    - Where $v$: signature recovery ID / chain ID; $r$ & $s$: signature values
    - But signature is on $keccak_{256}\bigg(RLP\Big([nonce, gasPrice, gasLimit, to, value, data]\Big)\bigg)$
  - [Type 1](https://eips.ethereum.org/EIPS/eip-2930) tx: $01_{16} \parallel RLP\Big([chainId, nonce, gasPrice, gasLimit, to, value, data, accessList, yParity, r, s]\Big)$
  - [Type 2](https://eips.ethereum.org/EIPS/eip-1559) tx: $02_{16} \parallel RLP\Big([chainId, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit,\\ to, value, data, accessList, yParity, r, s]\Big)$
- **Blocks & headers** — block header fields: RLP-encoded before hashing.
- **State trie nodes** — Merkle-Patricia trie from last section: stores RLP-encoded nodes.
- So RLP: *underneath* signatures, hashes & Merkle roots we covered: byte layer they all operate on.

</v-clicks>

<!--
- [click]
- [click] These are the bytes that are exchanged over the network.
- [click] We talked about RLP used for signing.
- So on what RLP do we do signature?
- [click] There was a replay risk with the ETC fork.
- [click] It got fixed with chainId in the signing parameters.
- Another network that copied another's id would be suspicious.
- People would not put valuables on it.
- [click] Then there was a change in gas parameters.
- [click] Blocks are not signed in PoW.
- In PoS, block signatures are stored in the beacon chain.
- [click] If you want to have fun with mixing hashes and RLP encoding.
-->