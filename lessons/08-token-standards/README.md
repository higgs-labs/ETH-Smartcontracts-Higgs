# Lesson 8 — Token standards (ERC-20 / ERC-721)

**Duration:** ~60 min · **Mode:** live-along, local Foundry

**Practice:** move the Lesson 5 `Escrow` from ETH to an ERC-20 in three steps, updating the Lesson 6 tests each time. Then reward backers with an ERC-721.

## Objective

Understand what an ERC is, what ERC-20 and ERC-721 standardise, and why a contract is not notified when it receives ERC-20 tokens. Build the Escrow on a stable token, then award one NFT per backer.

## Learning outcomes

Attendees can:

- Explain EIP vs ERC, and why a standard is an interface plus expected behaviour.
- Explain the six ERC-20 functions, decimals, and `approve` / `transferFrom`.
- Explain why "transfer then notify" is unsafe, and what a callback (ERC-1363, `safeTransferFrom`) fixes and costs.
- Use `SafeERC20` and the allowance pattern.
- Explain ERC-721 and compare ways to award a badge once per backer.

## Escrow, step by step

| Step | Tokens come in via | Flaw |
| --- | --- | --- |
| 1. Naive | `transfer`, then `pledge()` using the balance difference | Credit can be front-run |
| 2. Callback | ERC-1363 `transferAndCall` → `onTransferReceived` | Needs a non-standard token, callback surface |
| 3. Allowance | `approve` + `transferFrom` via `SafeERC20` | Approval hygiene |

Steps 1 and 2 are shown on the slides only. Step 3 is the code in `code/src/`.

## Badge uniqueness options

Flag mapping, `balanceOf` check (broken by transfers), deterministic id `uint160(backer)` (implemented), soulbound, flag inside the NFT.

## The code

Foundry project in [`code/`](./code/):

- [`src/Escrow.sol`](./code/src/Escrow.sol) and [`src/Escrow.t.sol`](./code/src/Escrow.t.sol) — final ERC-20 Escrow and tests.
- [`src/CampaignToken.sol`](./code/src/CampaignToken.sol) — capped ERC-20 standing in for a stablecoin.
- [`src/BackerBadge.sol`](./code/src/BackerBadge.sol) — ERC-721, id = backer address.
- [`src/BadgeEscrow.sol`](./code/src/BadgeEscrow.sol) and [`src/BadgeEscrow.t.sol`](./code/src/BadgeEscrow.t.sol) — Escrow with `claimBadge()`.
- [`src/IBadgeEscrow.sol`](./code/src/IBadgeEscrow.sol) — the interface the badge expects. `BackerBadge.addEscrow` checks it with ERC-165 (catches mistakes, not attackers: the allowlist still decides who can mint).

```bash
cd code
forge install OpenZeppelin/openzeppelin-contracts foundry-rs/forge-std
forge test -vvv
```

`refund()` now also requires the goal not to be reached, so a funded campaign cannot be refunded after a badge was claimed.

## Common pitfalls

- Forgetting `decimals` scaling.
- Assuming a contract is notified of an ERC-20 transfer.
- Skipping the `msg.sender == token` check in a callback.
- Infinite approvals.
- Using `balanceOf` to enforce one badge per backer.
