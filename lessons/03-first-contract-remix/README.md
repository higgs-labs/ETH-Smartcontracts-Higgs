# Lesson 3 — Your first smart contract in Remix

**Duration:** ~60 min · **Mode:** live-along in the browser

**Practice:** everyone deploys a contract to the Remix VM and to Sepolia.

## Objective

Write, compile, deploy, and interact with a minimal Solidity contract entirely in the browser — no local setup. Introduce Solidity's essentials with the concept-first framing, and make the read-vs-write / gas distinction concrete.

## Learning outcomes

Attendees can:

- Read and write a minimal contract (state variable, functions, `public`, `view`).
- Explain compile → bytecode → deploy → interact.
- Tell a **read** (view call, free) from a **write** (transaction, costs gas).
- Deploy to an in-browser VM and to a public testnet, and read state back.

## Concept-before-tool

**Remix** is the tool. Introduce it as "an IDE, compiler, and deployer in one browser tab" and show the three panels (editor, compiler, deploy) before typing code. The concept it makes visible: the *compile → deploy → interact* loop.

## Timing

| Time    | Segment | Notes |
| ------- | ------- | ----- |
| 0:00–0:05 | Recap take-home | "What did you pay for?" → gas = paying for a write. |
| 0:05–0:12 | Remix tour | Editor, Solidity compiler, Deploy & Run panels. |
| 0:12–0:25 | Write `Counter` | Live-along. `uint256`, `public`, functions. |
| 0:25–0:35 | Compile & deploy (VM) | Deploy to the in-browser VM; call `increment` / read `number`. |
| 0:35–0:45 | Read vs write | Blue (read, free) vs orange (write, tx + gas). Watch the tx in the log. |
| 0:45–0:57 | Deploy to Sepolia | Switch env to "Injected Provider — MetaMask"; confirm the tx; find it on Etherscan. |
| 0:57–1:00 | Recap + take-home | |

## Talking points

- **Pragma & license.** `// SPDX-License-Identifier` and `pragma solidity` — why   the compiler nags. Pin the version.
- **State lives on-chain.** `number` is not a variable in RAM; it's a storage slot replicated across the network. That's why changing it costs gas.
- **`public` generates a getter.** No boilerplate accessor needed.
- **`view` promises no state change** → can be called for free (no transaction).
- **Deploy = send the bytecode as a transaction.** The returned address is where the contract now lives.
- **Same code, two environments.** The Remix VM is a throwaway local sandbox; Sepolia is a real, shared, persistent testnet. The workflow is identical — that's the point.

## The contract

See [`code/starter/Counter.sol`](./code/starter/Counter.sol) (fill-in) and [`code/solution/Counter.sol`](./code/solution/Counter.sol).

## Hands-on

1. Paste the starter into Remix, complete the TODOs.
2. Compile (watch for the green check).
3. Deploy to the **Remix VM**, call `increment()`, read `number`.
4. Switch environment to **Injected Provider — MetaMask** (Sepolia).
5. Deploy to Sepolia, confirm in MetaMask, open the tx on Etherscan.

## Take-home

Add a `decrement()` function that reverts if `number` is already 0 (use `require`). Redeploy to Sepolia and share the contract address. We'll discuss `require` and reverts next lesson.

## Common pitfalls

- Wrong compiler version vs the pragma.
- Forgetting to switch MetaMask to Sepolia before the "injected" deploy.
- Expecting a `view` call to show up as a transaction — it won't.

## Success check

A contract deployed on Sepolia whose `number` each attendee can read and change from Remix.
