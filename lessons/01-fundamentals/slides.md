---
theme: default
title: "Lesson 1 — Blockchain fundamentals: the building blocks"
info: |
  In-person Ethereum & Solidity course.
  Lesson 1: the cryptographic and networking primitives a blockchain is built from
  — hashes, keys, signatures, Merkle trees, and the P2P protocol.
class: text-center
transition: slide-left
mdc: true
---

# Ethereum & Solidity for developers

<!--
- It's first time I do this one, with a presentation.
- Structure:
  - Fundamentals.
  - Experiment easy way - hands on from then on
  - Do some Solidity.
  - Do better with tests.
  - Deeper looks.
  - Build your own.
- Not sure how long the fundamentals will take.
- We'll adjust as we go.
- Also other sessions will be adjusted.
- It is being recorded.
- The content is a repo, private at the moment.
- Shows of hands:
  - Zero blockchain / some blockchain
  - Want to learn / want to build
-->

---
layout: section
---

# Blockchain fundamentals

### The building blocks, before the buzzwords

Lesson 1 · Ethereum & Solidity for developers

---

# Why this lesson exists

<v-click>

Before we touch Ethereum, we assemble the primitives a blockchain is made of.

</v-click>
<v-click>

- **Hash functions** — tamper-evident fingerprints

</v-click>
<v-click>

- **Public-key cryptography** — identity without a central registrar

</v-click>
<v-click>

- **Digital signatures** — approve documents, authenticate without revealing the secret key

</v-click>
<v-click>

- **Merkle trees** — prove one item belongs to a huge set, cheaply

</v-click>
<v-click>

- **RLP** - deterministic encoding for Ethereum

</v-click>
<v-click>

- **P2P networking** — no server, no single point of failure

</v-click>
<v-click>

A blockchain is not one invention. It is these old, well-understood pieces combined in a new way.

</v-click>

<!--
- The invention of blockchain did not happen out of thin air.
- It is the result of a multitude of inventions that were combined together into a new form.
- Knowing them will help you intuit instead of second-guess.
- [click] These inventions happened over the years, decades even, and here is the important subset.
- You know functions.
- You have seen them for a long time.
- [click] Hash functions are a particular set of functions.
- They allow you prove, for instance, that 2 copies are identical.
- All without disclosing the potentially-large or confidential content.
- [click] Then, we have cryptography.
- You already have some concepts about it, for instance when you use HTTPS.
- Here we will be looking into some detail as to how it is used for signatures.
- And in effect act as a proto identity.
- [click] With this cryptography, we can then use it to sign documents.
- This means that we put our stamp of approval on them.
- And in particular, if this document is a transaction, i.e. a call to action, then this action is understood to be approved, endorsed.
- [click] We will also look at a specific use of hash functions.
- Where we create a tree all linked by hash.
- Which will be useful to prove belonging.
- [click] Then we will look at something a little bit close to the metal.
- That is: how do we encode something in a deterministic way so that different machines can reproduce the same things now and forever.
- [click] We will have a quick look at peer-to-peer networking which relies on no central authority.
- [click] So there you have it a blockchain is a combination of previous inventions.
-->

---
clicks: 7
---

# The one-sentence definition

A blockchain is an **append-only, replicated log**, shaped as a giant hash-graph, that strangers agree on **without a central authority**.

<v-clicks>

Each of today's primitives answers one question that definition raises:

</v-clicks>
<v-clicks>

| Question | Primitive |
| -------- | --------- |
| How do we detect tampering? | <span v-if="$clicks >= 3">**Hashes**</span> |
| How do we know who did what? | <span v-if="$clicks >= 4">**Keys + signatures**</span> |
| How do encode identical content? | <span v-if="$clicks >= 5">**RLP**</span> |
| How do we prove membership cheaply? | <span v-if="$clicks >= 6">**Merkle trees**</span> |
| How does the log spread with no server? | <span v-if="$clicks >= 7">**P2P protocol**</span> |

</v-clicks>

<!--
- Append-only log means that we only add to it. Never modify or delete.
- A hash graph means that all data is pointed at by its hash. No auto-incrementing `account_id`.
- The network reaches its state by consensus.
- There is no central authority that you trust and that tells you what the state is.
- [click] We can review what we will learn.
- Shout the answer.
-->

---
src: ./slides-hash.md
---

---
src: ./slides-keys.md
---

---
src: ./slides-tx.md
---

---
src: ./slides-merkle.md
---

---
src: ./slides-rlp.md
---

---
layout: center
---

## Take-home

Pick any file on your machine.

1. Hash it with `sha256sum` (or `shasum -a 256`).
2. Change one character and hash it again. Watch the avalanche.
3. Ask yourself: *if a block header commits to a Merkle root, why can't anyone quietly edit an old transaction?*
4. Search for the zoo of consensuses.

Bring your answer to **Lesson 2 — Why Ethereum**.
