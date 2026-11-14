# Learn Ethereum and Smart Contracts

A hands-on **Ethereum & Solidity** course for TypeScript-fluent developers with
no prior blockchain experience. Over 10 in-person lessons (~1 hour each),
everyone ships a dApp — the strongest attendees gain broad literacy across the
whole stack.

Slides are built with [Slidev](https://sli.dev/); contract work uses
[Foundry](https://book.getfoundry.sh/), [OpenZeppelin](https://www.openzeppelin.com/contracts),
and [viem](https://viem.sh/).

## Repository layout

| Path | Contents |
| ---- | -------- |
| [`lessons/`](./lessons/) | The course itself — 10 lessons, prerequisites, and the instructor guide. Start at [`lessons/README.md`](./lessons/README.md). |
| [`lessons/PREREQS.md`](./lessons/PREREQS.md) | Setup every attendee completes before Lesson 4 (wallet, Node.js, Foundry). |
| `full-online-course/` | Git submodule: the original long-form course this material is adapted from. |

Each lesson folder contains an instructor `README.md`, a Slidev `slides.md`
deck, and a `code/` directory where relevant.

## Getting started

Requires [Node.js](https://nodejs.org/) — see [`.nvmrc`](./.nvmrc) for the
pinned version (v22+).

```bash
# install dependencies
npm install

# run the Slidev dev server (loads slides.md from the current folder)
npm run dev
```

To present a specific lesson, run Slidev from that lesson's folder:

```bash
npx slidev slides.md   # from e.g. lessons/02-why-ethereum/
```

## Troubleshooting

### `npm run dev*` fails with "Cannot find native binding" / `@rolldown/binding-darwin-*`

Slidev's bundler (rolldown) ships its native binary as a platform-specific optional dependency. npm sometimes fails to install it ([npm/cli#4828](https://github.com/npm/cli/issues/4828)), typically after switching Node versions, copying `node_modules`, or an interrupted install. When this happens, do a clean reinstall on the pinned Node version:

```bash
nvm use            # switch to the version in .nvmrc
rm -rf node_modules package-lock.json
npm install
```

Then rerun your `npm run dev:lessonNN` command. Make sure you are on the Node version in [`.nvmrc`](./.nvmrc) first — a mismatch (e.g. running v22.11 when v22.12+ is required) is a common trigger for the broken install.

## Autocomplete

To get Zsh to autocomplete `package.json`'s script commands, do:

```bash
autoload -Uz compinit && compinit
```

## Learn more

- Course overview and lesson index: [`lessons/README.md`](./lessons/README.md)
- Attendee setup: [`lessons/PREREQS.md`](./lessons/PREREQS.md)
