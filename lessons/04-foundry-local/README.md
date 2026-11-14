# Lesson 4 — Going local with Foundry

**Duration:** ~60 min · **Mode:** live-along on local machines (setup gate)
**Practice:** port the `Counter` into a Foundry project and deploy to `anvil`.

## Objective

Leave the browser. Introduce the local toolchain conceptually — a compiler, a
local node, and a CLI — then set up Foundry and reproduce Lesson 3 locally.

## Learning outcomes

Attendees can:

- Explain what `forge`, `cast`, and `anvil` each do.
- Scaffold a project with `forge init` and understand its layout.
- Compile with `forge build` and run a local chain with `anvil`.
- Deploy to `anvil` and call the contract with `cast`.

## Concept-before-tool

Introduce the three Foundry tools as concepts first:

- **`anvil`** — a local Ethereum node. "Your own private chain that resets when
  you stop it. Fast, free, and disposable."
- **`forge`** — build & test. "Compiler + test runner + deployer."
- **`cast`** — the CLI to talk to any chain. "curl for Ethereum."

Only then run them.

## Setup gate

> This lesson requires the [`PREREQS.md`](../PREREQS.md) setup. Open the room 15
> minutes early for troubleshooting. Anyone whose local install fails uses the
> **Codespaces fallback** so the room isn't blocked.

## Timing

| Time    | Segment | Notes |
| ------- | ------- | ----- |
| 0:00–0:08 | Why leave Remix? | Version control, tests, repeatability, real projects. |
| 0:08–0:15 | The three tools (concept) | anvil / forge / cast, before touching them. |
| 0:15–0:25 | `forge init` tour | `src/`, `test/`, `script/`, `foundry.toml`, `lib/`. |
| 0:25–0:35 | Port `Counter`, `forge build` | Read the compiler output & artifacts. |
| 0:35–0:45 | Start `anvil` | Read the dev accounts + private keys it prints. |
| 0:45–0:57 | Deploy & call | `forge create` to deploy; `cast call` / `cast send` to interact. |
| 0:57–1:00 | Recap + take-home | |

## Talking points

- **Why a local chain.** `anvil` is instant and free, so the dev loop is
  seconds, not testnet minutes. It resets on restart — good for experiments.
- **`anvil` prints funded dev accounts.** Those private keys are public and
  well-known; **never** use them outside a local chain. (Key-safety habit early.)
- **Project layout.** `src/` contracts, `test/` tests, `script/` deploy scripts,
  `lib/` dependencies (git submodules), `foundry.toml` config.
- **`cast call` vs `cast send`.** `call` reads (free, no tx); `send` writes
  (transaction). Same read/write split from Lesson 3, now on the CLI.
- **Artifacts.** `forge build` writes ABI + bytecode to `out/`. The ABI is the
  interface the front-end will later use (→ Lesson 10).

## Command walkthrough

```bash
# scaffold
forge init counter-project
cd counter-project

# drop Counter.sol into src/, then build
forge build

# in a second terminal: start a local chain
anvil
# note the first account address + private key it prints

# deploy (use one of anvil's dev keys — local only!)
forge create src/Counter.sol:Counter \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <ANVIL_DEV_KEY> \
  --broadcast

# interact
cast call <CONTRACT_ADDR> "number()(uint256)" --rpc-url http://127.0.0.1:8545
cast send <CONTRACT_ADDR> "increment()" \
  --rpc-url http://127.0.0.1:8545 --private-key <ANVIL_DEV_KEY>
cast call <CONTRACT_ADDR> "number()(uint256)" --rpc-url http://127.0.0.1:8545
```

## Hands-on

Reproduce the walkthrough: init, build, run anvil, deploy, and increment via
`cast`, confirming `number` went up.

## Take-home

From an empty folder, reproduce the entire local deploy from memory (init →
build → anvil → deploy → increment). If you get stuck, write down exactly which
step failed — we want to know what breaks.

## Common pitfalls

- Running `cast`/`forge create` against anvil while anvil isn't running.
- Using an anvil dev key on a real network (never do this).
- Forgetting `--broadcast` on `forge create` in newer Foundry versions.

## Success check

The `Counter` compiled and deployed on a local `anvil` chain, with `increment()`
confirmed via `cast`.
