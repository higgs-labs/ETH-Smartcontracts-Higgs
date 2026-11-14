# Ethereum & Solidity — In-Person Course

A 10-lesson, in-person course that takes TypeScript-fluent developers with no
blockchain experience to the point where **everyone can ship a dApp**, and the
strongest attendees gain broad literacy across the whole stack. An optional
**bonus lesson 12** opens the EVM's black box for the curious.

## Format

- **10 lessons, ~1 hour each.** Mixed theory and practice.
- **Audience:** experienced software developers, strong in TypeScript, no prior
  blockchain toolchain experience.
- **Room size:** 50–100 attendees. Practical work is designed to scale:
  browser tools (Remix) for the first lessons, then a local
  [Foundry](https://book.getfoundry.sh/) toolchain, plus occasional take-homes.
- **Teaching principle:** *concept before tool.* Every new tool is introduced
  with a quick "what it does" example, then explained conceptually, before we
  dive deeper.

## Tooling spine

| Layer            | Choice                                        |
| ---------------- | --------------------------------------------- |
| First contracts  | [Remix](https://app.remix.live/) (browser, no setup) |
| Contract dev     | [Foundry](https://book.getfoundry.sh/) — `forge`, `cast`, `anvil` |
| Testing          | `forge test` (Solidity-native) + cheatcodes   |
| Libraries        | [OpenZeppelin](https://www.openzeppelin.com/contracts) |
| Local chain      | `anvil`                                        |
| Public testnet   | Sepolia                                        |
| Front-end        | Vite + TypeScript + [viem](https://viem.sh/) (minimal SPA) |

## The running example

A single running contract (a simple **escrow / campaign**, extended into a
**token + vault** later) threads through the lessons, so each lesson is a
working, demoable increment with no orphaned code.

## Lessons

| #  | Lesson | Tool focus | Practice |
| -- | ------ | ---------- | -------- |
| 1  | [Blockchain fundamentals: the building blocks](./01-fundamentals/) | — | Hash a file, watch the avalanche |
| 3  | [Your first smart contract in Remix](./03-first-contract-remix/) | Remix | Deploy to Sepolia |
| 4  | [Going local with Foundry](./04-foundry-local/) | forge / cast / anvil | Local deploy |
| 5  | [Solidity deep dive](./05-solidity-deep-dive/) | Solidity | Extend the contract |

## Before you start

All attendees must complete [`PREREQS.md`](./PREREQS.md) **before Lesson 4**
(wallet from Lesson 2, Foundry + Node.js for the local lessons).

## Per-lesson layout

Each lesson folder contains:

- `README.md` — instructor guide: objectives, timing, talking points, take-home.
- `slides.md` — [Slidev](https://sli.dev/) deck (Markdown; Mermaid diagrams inline).
- `code/` — starter/solution Solidity, tests, scripts, or front-end where relevant.

### Running the slides

```bash
# from any lesson folder
npx slidev slides.md
```

## Source material

This course is a compressed, modernized adaptation of the team's
`full-online-course` (~30–40h, Truffle/web3-era). The conceptual backbone is
kept; the toolchain is modernized (Truffle/web3 → Foundry/viem) and the three
large projects are replaced by one incremental running example.
