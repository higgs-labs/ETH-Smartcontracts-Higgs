# Prerequisites & Setup — Lesson 4

Complete this **before Lesson 4**. Lessons 2–3 run entirely in the browser, but
setting up early means you won't lose class time to installation.

> This builds on the wallet setup from Lesson 2 — see
> [`../02-why-ethereum/PREREQS.md`](../02-why-ethereum/PREREQS.md) if you haven't
> installed MetaMask yet.

> If any step fails and you can't fix it before class, use the
> **[GitHub Codespaces fallback](#fallback-github-codespaces)** so one broken
> laptop doesn't stall the room.

## 1. Node.js (needed from Lesson 4, required for slides & front-end)

Install the current LTS of [Node.js](https://nodejs.org/) (v20+).

```bash
node --version   # should print v20.x or later
npm --version
```

## 2. Foundry (needed from Lesson 4)

Foundry is the contract toolchain: `forge` (build/test), `cast` (CLI calls),
`anvil` (local chain).

### macOS / Linux

```bash
curl -L https://getfoundry.sh/install | bash
foundryup
```

### Windows

Use **WSL2** (Ubuntu) and follow the macOS / Linux steps inside it.

### Verify

```bash
forge --version
cast --version
anvil --version
```

## 3. A code editor

[VS Code](https://code.visualstudio.com/) with these extensions:

- **Solidity** ([Juan Blanco](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity) or [Nomic Foundation](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity))
- Your usual TypeScript setup (for the Lesson 10 front-end)

## Fallback: GitHub Codespaces

If local setup fails, open the course repo in a
[GitHub Codespace](https://github.com/features/codespaces). A devcontainer with
Node.js and Foundry pre-installed lets you follow every lesson in the browser.

## Self-check before Lesson 4

- [ ] MetaMask installed, Sepolia added, test ETH received (from Lesson 2)
- [ ] `node --version` prints v20+
- [ ] `forge --version` works
- [ ] `anvil` starts and prints a list of dev accounts (Ctrl-C to stop)
