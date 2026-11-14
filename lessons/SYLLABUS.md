# Syllabus — Ethereum & Solidity (In-Person Course)

A 10-lesson, in-person course (plus one bonus) that takes TypeScript-fluent developers with **no blockchain experience** to the point where everyone can **ship a dApp end-to-end**. The strongest attendees leave with literacy across the whole stack.

- **Format:** 10 core lessons + 1 bonus, ~60 min each. Mixed theory and practice.
- **Audience:** experienced software developers, strong in TypeScript, no prior blockchain toolchain experience.
- **Room size:** 50–100 attendees.
- **Teaching principle:** *concept before tool* — every tool arrives with a quick "what it does," then the concept, then the deep dive.
- **Running example:** a single **crowdfunding `Escrow`** (extended into a **token + vault**) threads through the course, so every lesson is a working, demoable increment.

## Tooling spine

| Layer           | Choice                                                 |
| --------------- | ------------------------------------------------------ |
| First contracts | Remix (browser, no setup)                              |
| Contract dev    | Foundry — `forge`, `cast`, `anvil`                     |
| Testing         | `forge test` (Solidity-native) + cheatcodes            |
| Libraries       | OpenZeppelin                                           |
| Local chain     | `anvil`                                                |
| Public testnet  | Sepolia                                                |
| Front-end       | Vite + TypeScript + viem (minimal SPA)                 |

## Before you start

Complete [`PREREQS.md`](./PREREQS.md) **before Lesson 4**: a fresh MetaMask wallet (Lesson 2), then Node.js v20+ and Foundry for the local lessons. A GitHub Codespaces fallback exists for anyone whose local setup fails.

## Course map at a glance

| #  | Lesson | Tool focus | Practice / deliverable |
| -- | ------ | ---------- | ---------------------- |
| 1  | [Blockchain fundamentals: the building blocks](./01-fundamentals/) | — | Hash a file, observe the avalanche |
| 3  | [Your first smart contract in Remix](./03-first-contract-remix/) | Remix | `Counter` deployed to Sepolia |
| 4  | [Going local with Foundry](./04-foundry-local/) | forge / cast / anvil | `Counter` on local anvil |
| 5  | [Solidity deep dive](./05-solidity-deep-dive/) | Solidity | The `Escrow` running example |

---

## Lesson 1 — Blockchain fundamentals: the building blocks

**Tool focus:** — · **Mode:** theory-forward, no toolchain

Assemble the primitives a blockchain is made of, *before* touching Ethereum: cryptographic hashes (and the Proof-of-Work mining game they enable), public-key cryptography, digital signatures, what a transaction *is*, Merkle trees, RLP encoding, the P2P protocol, and consensus. The throughline is tamper-evidence — how a chain of hashes, signed transactions, and Merkle roots makes an append-only log — capped by consensus, which lets strangers agree on one chain without a central authority. The lesson closes with how shared state is actually stored (UTXO vs account model) and why using the network costs gas.

**Outcomes** — explain what a hash guarantees and why blocks link via the previous hash; explain the Proof-of-Work mining game (nonce, target, difficulty) and why it's expensive to produce yet cheap to verify; describe a key pair and how an address derives from a public key; explain how a signature authenticates without revealing the secret; define a transaction as an atomic, signature-authorised, state-changing event; describe a Merkle proof and why it costs only `log(n)` hashes; explain why structured data is RLP-encoded before hashing/signing; contrast centralised/decentralised/distributed topologies and the role of P2P gossip; explain why open networks need consensus, how Sybil resistance works, and the difference between Proof of Work and Proof of Stake; contrast the UTXO model (Bitcoin, Corda) with the account model (Ethereum); and explain why blockspace is scarce and what gas and gas price meter.

**Practice:** hash a file with `sha256sum`, change one character, and watch the digest change completely.

**Take-home:** confirm the avalanche effect on a file of your own, answer *"if a block header commits to a Merkle root, why can't anyone quietly edit an old transaction?"*, and go search for the "zoo" of consensus mechanisms beyond PoW and PoS.

## Lesson 3 — Your first smart contract in Remix

**Tool focus:** Remix · **Mode:** live-along in the browser

Write, compile, deploy, and interact with a minimal contract entirely in the browser — no local setup. Make the read-vs-write / gas distinction concrete.

**Outcomes** — read/write a minimal contract (state variable, `public`, `view`); explain compile → bytecode → deploy → interact; tell a free **read** from a gas-costing **write**; deploy to the Remix VM and to Sepolia.

**Practice:** complete the `Counter` starter, deploy to the Remix VM, then redeploy to Sepolia via injected MetaMask and view the tx on Etherscan.

**Take-home:** add a `decrement()` that reverts at 0 with `require`; redeploy.

## Lesson 4 — Going local with Foundry

**Tool focus:** `forge` / `cast` / `anvil` · **Mode:** live-along (setup gate)

Leave the browser. Introduce the local toolchain conceptually, set up Foundry, and reproduce Lesson 3 locally.

**Outcomes** — explain what `forge`, `cast`, and `anvil` each do; scaffold with `forge init` and understand the layout; build with `forge build` and run a local chain; deploy to anvil and call via `cast`.

**Practice:** init a project, build `Counter`, run anvil, deploy, and `increment()` via `cast`.

**Take-home:** reproduce the whole local deploy from memory; note exactly which step breaks.

> ⚠️ **Setup gate:** requires `PREREQS.md`. Open the room 15 min early for troubleshooting; Codespaces fallback for broken installs.

## Lesson 5 — Solidity deep dive

**Tool focus:** Solidity (the language) · **Mode:** live-along, local Foundry

Move beyond toy contracts and start the **running example**. Introduce mappings, structs, events, modifiers, custom errors, visibility, and the ether-handling model — each as the solution to a concrete problem.

**Outcomes** — model per-address state with mappings/structs; emit events and explain why `indexed` matters; guard functions with modifiers and revert with custom errors; receive/send ETH (`payable`, `msg.value`, `call`) and reason about `msg.sender`.

**Practice:** complete the `Escrow` starter, deploy to anvil, pledge from two accounts, and watch `totalPledged` and `Pledged` events.

**Take-home:** add an owner-only `setGoalReachedMessage(string)` — tested next lesson.

---

## Per-lesson layout

Each lesson folder contains:

- `README.md` — instructor guide: objectives, timing, talking points, take-home.
- `slides.md` — Slidev deck (Markdown; Mermaid diagrams inline).
- `code/` — starter/solution Solidity, tests, scripts, or front-end where relevant.

Run any deck from its lesson folder with `npx slidev slides.md`.
