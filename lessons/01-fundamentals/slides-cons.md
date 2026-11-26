---
layout: section
---

# 7. Consensus

How strangers agree which block is next

And hence the state of the world

---

# State of the world

Of the *blockchain* world

<v-clicks depth="2">

- Transactions:
  - Which ones?
  - In which order?
  - → results in a state.
- Who decides?

</v-clicks>

<!--

- [click:5]
- And that's not all.
- There are consequences to choices made.

-->

---

# Nice-to-have or important?

Double-spend problem

<v-clicks depth="2">

- Digital artefacts can be copied, think photos. But money? Send:
  - $tx_B$: Alice sends $coin_1$ to Bob: _give to Bob_. Bob accepts $coin_1$ as payment.
  - $tx_C$: Alice sends same $coin_1$ to Carol: _give to Carol_. Carol accepts same $coin_1$ as payment 🥷.
- Sending a bitcoin & seeing it in a block → cannot be spent again (by protocol).
  - Safe condition: Bob and Carol see the same block.
- Problem / attack: send two $N+1$ blocks with different $tx_?$:
  - $block_B$: with $tx_B$, Bob sees $block_B$ first, accepts $coin_1$ as payment.
  - $block_C$: with $tx_C$, Carol sees $block_C$ first, accepts $coin_1$ as payment.
- How to do?

</v-clicks>

<!--
- [click:2]
- [click] Sending a tx to someone is not good enough.
-->

---

# Making explicit the attack example

<v-clicks depth="2">

- Bob sees $block_B$ with $tx_B$:
  - Bob accepts payment from Alice, sends goods.
- Network decides $block_C$ with $tx_C$ is the block to keep:
  - Carol accepts payment from Alice, sends goods.
  - Bob's payment has disappeared from the accepted world state. 💸
  - Bob has delivered goods. 🥶
- Mitigation: wait for further blocks → reorganisation less likely.

</v-clicks>

---

# What blockchain blocks solve

Blocks + consensus

<v-clicks depth="3">

- A block tells what is in it.
  - The protocol (& an honest node) can prevent $tx_B$ and $tx_C$ (spending same $coin_1$) from being in the same block.
  - But 2 incompatible sibling (height $N$) blocks can be manufactured; unless?
- Unless it is expensive to create a block / a sibling block.
  - How do we make a block expensive to create?
  - Or expensive to renege on.
- Main consensuses:
  - Proof-of-work: you and your malicious cartel cannot overwhelm the hashing capacity of the honest nodes.
  - Proof-of-stake: validators sign their preferred height-$N$ block. 50+% stake signed?
    - You lose part of your stake when you behave poorly. e.g. sign 2 sibling blocks.
- Eventual consistency: network converges on a single fork, 1 chain.

</v-clicks>

<!--
- [click:7]
- [click] A malicious cartel would have to be able to create 2 incompatible blocks.
- And distribute them to different parties without the honest nodes to even create one.
- [click] This is an extremely simplified version.
- [click] Honest validators should be careful not to make mistakes.
- [click] Consensus is the set of rules that makes the whole network converge on **one** chain.
-->

---

# Why you can't just vote

<v-clicks depth="2">

- Naive consensus: "let nodes vote, majority wins". Fails on an open network.
  - Identities are **free**. Anyone can spin up a million nodes for near-nothing.
  - A majority *of nodes* → means nothing. Attacker fakes majority.
  - This is the **Sybil attack**. Public blockchains defeat it by tying **influence** to a **scarce, costly resource** instead of to identities.
- Proof-of-Work → influence costs **energy**.
- Proof-of-Stake → influence costs **capital at risk**.

</v-clicks>

<!--
- Belabouring the point.
- [click]
- [click] See vanity addresses.
-->

---

# Proof of Work

Revisiting earlier points

<v-clicks>

- To propose a block, find a nonce so that $hash(blockHeader) < target$.
  - Solvable only by brute force.
- Finding: **expensive** (energy); checking: **instant** (1 hash).
- Rewriting history? → redoing all that work faster than the honest majority → economically hopeless.
- "Longest / heaviest chain": the one with the most work behind it. That's the fork-choice rule.
  - Bitcoin still runs on PoW.

</v-clicks>

---

# Proof of Stake

Ethereum since **The Merge**, Sept 2022

<v-clicks depth="2">

- A validator locks up **32 ETH** as a stake.
- Protocol picks a validator to propose each block.
- A committee **attests** that it's valid.
- Misbehave — equivocate or attack — and your stake is **slashed** (burned).
  - No signing 2 blocks at height $N$.
  - No forgetting to sign.
- Honesty is the profitable strategy.
  - Attacking means destroying your own money.
  - Same goal as PoW, a fraction of the energy.

</v-clicks>

---

# Finality & eventual consistency

<v-clicks>

- When a fork happens in PoW:
  - Fork-choice rule picks a winner. Network **converges** — this is *eventual* consistency.
- $tx_1$ gets safer the more blocks are built on top of it (aka confirmations).
- PoS adds **finality**: once a supermajority attests, reverting would cost attackers a large share of all staked ETH — so it's treated as irreversible.
- → we say a blockchain is a log *"strangers eventually agree on, without a central authority."*
  - Consensus is the "eventually agree" part.

</v-clicks>

---
layout: center
---

## Recap

The five primitives and what each buys you:

<div style="font-size:0.6em;">

| Primitive | Guarantee |
| --------- | --------- |
| Hash function | tamper-evidence + linking |
| Public/private keys | identity without a registrar |
| Digital signature | authorization + integrity |
| Merkle tree | cheap membership proofs |
| P2P protocol | no single point of failure |
| RLP encoding | deterministic bytes to hash & sign |
| Consensus (PoW/PoS) | one agreed chain, no central authority |

</div>

A **transaction** is where these meet: a signed, RLP-encoded, atomic event that P2P spreads, Merkle roots commit to, and consensus makes final.

Consensus ties them together into one agreed chain.

<!--
- Next, let's see at how the world is described.
-->