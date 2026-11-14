---
layout: section
---

# 1. Hash functions

The tamper-evident fingerprint

---

# What a cryptographic hash does

<v-click>

$hash(message)=digest$

Requirements:

</v-click>

<v-clicks>

- **Fixed-size** digest, from any size message
- **Fast** to compute in one direction.
- **One-way** — practically impossible to recover the message from the digest. <span v-if="$clicks == 3"><br/>$x^2+3*x+5$ will not do</span>
- **Avalanche** — the tiniest change to the input scrambles the output completely. [sha256](https://emn178.github.io/online-tools/sha256.html)
- **Collision-resistant** — practically impossible to find two messages with the same digest.
- It follows it needs to be **evenly distributed** -- no guessing where it is likely to fall.

</v-clicks>
<v-clicks>

Like a fingerprint: short, unique, and impossible to work backwards from. The only way back is:

</v-clicks>
<v-clicks>

- Brute-forcing it
- Building a lookup table of candidates.

</v-clicks>
<v-clicks>

And now for an artisanal hashing... 🙃

</v-clicks>

<!--
- A hash function maps any input (the message) to a fixed-size output (the digest).
- [click] To qualify it needs a few features.
- [click] Fixed size makes sure you can guess even less.
- [click] "Fast" is of course relative.
- [click] It acts as a trap door.
- You cannot find correlations between a change in the message and a change 
- [click] You cannot control the amount of change in the digest by controlling something in the message.
- [click] The digest space is so large that it takes a long time to fall again on the same value.
- [click] No Gaussian distribution. No clumping on the side.
- [click:2] Trying everything until you get a hit.
- [click] Using a lot of memory or disk instead of compute.
-->

---
layout: full
---

<Youtube id="y3dqhixzGVo" width="100%" height="100%" />

---

# See the avalanche effect

````md magic-move
```bash
$ echo "The quick brown fox jumps over the lazy dog" | sha256sum
```
```bash
$ echo "The quick brown fox jumps over the lazy dog" | sha256sum
c03905fcdab297513a620ec81ed46ca44ddb62d41cbbd83eb4a5a3592be26a69
#23456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0 (64 hex chars)
```
```bash
$ echo "The quick brown fox jumps over the lazy dog" | sha256sum
c03905fcdab297513a620ec81ed46ca44ddb62d41cbbd83eb4a5a3592be26a69
#                              ⬇
$ echo "The quick brown fox jump over the lazy dog" | sha256sum
```
```bash
$ echo "The quick brown fox jumps over the lazy dog" | sha256sum
c03905fcdab297513a620ec81ed46ca44ddb62d41cbbd83eb4a5a3592be26a69

$ echo "The quick brown fox jump over the lazy dog" | sha256sum
2d9b43c2c667037f0096d5c3c4713f85024a2552521d75bb2fff4016052bd23b # (completely different)
```
```bash
$ echo "The quick brown fox jumps over the lazy dog" | sha256sum

$ echo "The quick brown fox jump over the lazy dog" | sha256sum
2d9b43c2c667037f0096d5c3c4713f85024a2552521d75bb2fff4016052bd23b
c03905fcdab297513a620ec81ed46ca44ddb62d41cbbd83eb4a5a3592be26a69
#                     ^                                            (same char) 
```
````

<div v-if="$clicks==0">

We take a message and hash it.

</div>
<div v-if="$clicks==1">

Note the fixed size.

</div>
<div v-if="$clicks==2">

Now a small change.

</div>
<div v-click="3">

Message: one character changed -> the two digests: *nothing* in common.

A hash is **tamper-evident**: change one byte anywhere, -> the fingerprint no longer matches.
<br/>You cannot try approximations to get to a desired message. No binary search.

</div>

<!--
- We are going to hash 2 similar messages.
- [click:2] Who wants to guess the hash?
-->

---

# Hash lookup table

Store digests ahead of time

<v-clicks depth="2">

- Not to mistake for a hash table.
- A legitimate use: Ethereum's [function selector](https://www.4byte.directory) lookup (see lessons 3&4).
- Example of risk: sealed envelope with price: $hash(123\,456\,789)$ -> hash lookup table has 1B digests.
- Common mitigation: **salting**: $hash(123\,456\,789 \parallel salt_{256})$. $salt$ has $2^{256}$ possibilities.
  - Later disclose: $price$ & $salt$. Typical commit / reveal scheme.
  - Same with passwords.

</v-clicks>

<!--
- They exist, and your system should account for them.
- [click] A hash table stores content in an array, whose index is the hash of the key.
- [click] Example: `0x8381f58a`
- Imagine you are bidding for a new road, the price can go up to a billion dollars.
-->

---

# Which hash does what

Depends on what you want to protect against

<v-clicks depth="2">

- Bitcoin uses **SHA-256**.
- Ethereum uses **Keccak-256** (often loosely called **SHA-3**).
  - For mapping keys, function selectors, event topics, and commit-reveal schemes.
- **MD5** and **SHA-1** are broken — collisions have been found (Google's SHATTERED attack on SHA-1, 2017). Do not use them for security.
- **Argon2**: Password hashing

</v-clicks>

<!--
- [click:5] Now let's look at the chain in blockchain.
-->

---

# Why hashes matter for a blockchain: linking

3 uses you will see everywhere:

<v-clicks depth="2">

- **Linking blocks**: each block stores hash of previous block.
  - Change an old block and every later hash breaks. That is the *chain*.

</v-clicks>
<v-click>

<!-- Single morphing SVG: chain (click 3) -> fork (click 4) -> settled (click 5). -->
<!-- N-1 and N are always present; only the right-hand successor(s) morph. -->
<!-- Each state group cross-fades via an inline opacity transition tied to $clicks (per-slide counter). -->

<svg viewBox="-1 -1 602 214" width="602" height="218" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, sans-serif" style="width: 100%; max-width: 602px; height: auto; display: block; margin: 0 auto">
  <defs>
    <marker id="arrow-morph" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="#64748b" />
    </marker>
  </defs>

  <!-- shared arrow: N-1 <- N (always visible) -->
  <path d="M210,102 L160,102" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#arrow-morph)" />

  <!-- Block N-1 (always) -->
  <g>
    <rect x="0" y="62" width="160" height="80" rx="10" fill="#eef2ff" stroke="#6366f1" stroke-width="2" />
    <text x="80" y="86" text-anchor="middle" style="font-size: 15px; font-weight: 700" fill="#312e81">Block N-1</text>
    <text x="80" y="108" text-anchor="middle" style="font-size: 13px" fill="#4338ca">prev: ...</text>
    <text x="80" y="128" text-anchor="middle" style="font-size: 13px" fill="#4338ca">hash: a1b2</text>
  </g>

  <!-- Block N (always) -->
  <g>
    <rect x="210" y="62" width="160" height="80" rx="10" fill="#eef2ff" stroke="#6366f1" stroke-width="2" />
    <text x="290" y="86" text-anchor="middle" style="font-size: 15px; font-weight: 700" fill="#312e81">Block N</text>
    <text x="290" y="108" text-anchor="middle" style="font-size: 13px" fill="#4338ca">prev: a1b2</text>
    <text x="290" y="128" text-anchor="middle" style="font-size: 13px" fill="#4338ca">hash: c3d4</text>
  </g>

  <!-- STATE: chain (single successor), shown on click 3 only -->
  <!--g :style="{ opacity: $clicks === 3 ? 1 : 0, transition: 'opacity 400ms ease', pointerEvents: 'none' }">
    <path d="M420,102 L370,102" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#arrow-morph)" />
    <rect x="420" y="62" width="160" height="80" rx="10" fill="#eef2ff" stroke="#6366f1" stroke-width="2" />
    <text x="500" y="86" text-anchor="middle" style="font-size: 15px; font-weight: 700" fill="#312e81">Block N+1</text>
    <text x="500" y="108" text-anchor="middle" style="font-size: 13px" fill="#4338ca">prev: c3d4</text>
    <text x="500" y="128" text-anchor="middle" style="font-size: 13px" fill="#4338ca">hash: e5f6</text>
  </g-->

  <!-- STATE: fork + settle, shown from click 4 onward.
       - branch B (amber) and the fork arrows appear only at the fork step, then fade.
       - branch A (green) is PERSISTENT: on settle it slides down-left into the winning
         slot and its colours fade green -> blue. Its arrow travels with it. -->
  <g v-if="$clicks !== 3">
    <!-- fork-only pieces: branch B (amber) + the two fork arrows. Fade out on settle. -->
    <g :style="{ opacity: $clicks === 4 ? 1 : 0, transition: 'opacity 400ms ease', pointerEvents: 'none' }">
      <!-- arrow N -> branch A (fork angle) -->
      <path d="M440,42 L390,92" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#arrow-morph)" />
      <!-- arrow N -> branch B (fork angle) -->
      <path d="M440,182 L390,112" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#arrow-morph)" />
      <!-- branch B (amber, loses) -->
      <rect x="440" y="134" width="160" height="80" rx="10" fill="#fff7ed" stroke="#f59e0b" stroke-width="2" />
      <text x="520" y="158" text-anchor="middle" style="font-size: 15px; font-weight: 700" fill="#9a3412">Block N+1</text>
      <text x="520" y="180" text-anchor="middle" style="font-size: 13px" fill="#b45309">prev: c3d4</text>
      <text x="520" y="200" text-anchor="middle" style="font-size: 13px" fill="#b45309">hash: f1a6</text>
    </g>
    <!-- settled arrow: horizontal N -> winner. Fades IN as the fork arrow to A fades out. -->
    <path d="M420,102 L370,102" stroke="#64748b" stroke-width="2" fill="none" marker-end="url(#arrow-morph)"
          :style="{ opacity: ($clicks !== 3 && $clicks !== 4) ? 1 : 0, transition: 'opacity 400ms ease' }" />
    <!-- PERSISTENT branch A: translates down-left (fork slot -> winner slot) and recolours.
         Fork slot rect is at (440,2); winner slot rect is at (420,62): delta = (-20, +60). -->
    <g :style="{ transform: ($clicks !== 3 && $clicks !== 4) ? 'translate(-20px, 60px)' : 'translate(0px, 0px)', transition: 'transform 500ms ease' }">
      <rect x="440" y="2" width="160" height="80" rx="10"
            :style="{ fill: ($clicks !== 3 && $clicks !== 4) ? '#eef2ff' : '#ecfdf5', stroke: ($clicks !== 3 && $clicks !== 4) ? '#6366f1' : '#10b981', transition: 'fill 500ms ease, stroke 500ms ease' }"
            stroke-width="2" />
      <text x="520" y="26" text-anchor="middle"
            :style="{ fill: ($clicks !== 3 && $clicks !== 4) ? '#312e81' : '#065f46', transition: 'fill 500ms ease', fontSize: '15px', fontWeight: 700 }">Block N+1</text>
      <text x="520" y="48" text-anchor="middle"
            :style="{ fill: ($clicks !== 3 && $clicks !== 4) ? '#4338ca' : '#047857', transition: 'fill 500ms ease', fontSize: '13px' }">prev: c3d4</text>
      <text x="520" y="68" text-anchor="middle"
            :style="{ fill: ($clicks !== 3 && $clicks !== 4) ? '#4338ca' : '#047857', transition: 'fill 500ms ease', fontSize: '13px' }">hash: e5f6</text>
    </g>
  </g>
</svg>

</v-click>
<div v-if="$clicks == 4">

- Vocabulary: that is a **fork**. Happens honestly or maliciously.

</div>
<div v-if="$clicks == 5">

- The consensus eventually picks one.

</div>
<v-clicks at="6" depth="2">

- **Content addressing**: refer to data by its hash instead of its location.
  - $key_{data}=hash(data)$ instead of "find $data$ at $key1$"".
  - IPFS, Git, and BitTorrent magnet links all do this.
- **Storage mapping**: pick a storage location that makes collisions unlikely: $key_{data}=hash(salt \parallel key)$

</v-clicks>

<!--
- Blocks come one after the other, and the next one stores the hash of the immediately earlier one.
- [click:3] We can see that nothing prevents another block from storing the same previous hash.
- [click] And indeed, forks happen.
- So how to choose which one?
- [click] That's one of the roles of the consensus.
- Not all graphics will be great like that.
- Another use of hashing in blockchain is content addressing.
-->

---

# Let's play a game: pick a cell and hash into it

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <g stroke="currentColor" stroke-width="1">
  <line x1="0" y1="0" x2="1024" y2="0"/>
  <line x1="0" y1="16" x2="1024" y2="16"/>
  <line x1="0" y1="32" x2="1024" y2="32"/>
  <line x1="0" y1="48" x2="1024" y2="48"/>
  <line x1="0" y1="64" x2="1024" y2="64"/>
  <line x1="0" y1="80" x2="1024" y2="80"/>
  <line x1="0" y1="96" x2="1024" y2="96"/>
  <line x1="0" y1="112" x2="1024" y2="112"/>
  <line x1="0" y1="128" x2="1024" y2="128"/>
  <line x1="0" y1="144" x2="1024" y2="144"/>
  <line x1="0" y1="160" x2="1024" y2="160"/>
  <line x1="0" y1="176" x2="1024" y2="176"/>
  <line x1="0" y1="192" x2="1024" y2="192"/>
  <line x1="0" y1="208" x2="1024" y2="208"/>
  <line x1="0" y1="224" x2="1024" y2="224"/>
  <line x1="0" y1="240" x2="1024" y2="240"/>
  <line x1="0" y1="256" x2="1024" y2="256"/>
  <line x1="0" y1="272" x2="1024" y2="272"/>
  <line x1="0" y1="288" x2="1024" y2="288"/>
  <line x1="0" y1="304" x2="1024" y2="304"/>
  <line x1="0" y1="320" x2="1024" y2="320"/>
  <line x1="0" y1="336" x2="1024" y2="336"/>
  <line x1="0" y1="352" x2="1024" y2="352"/>
  <line x1="0" y1="368" x2="1024" y2="368"/>
  <line x1="0" y1="384" x2="1024" y2="384"/>
  <line x1="0" y1="400" x2="1024" y2="400"/>
  <line x1="0" y1="416" x2="1024" y2="416"/>
  <line x1="0" y1="432" x2="1024" y2="432"/>
  <line x1="0" y1="448" x2="1024" y2="448"/>
  <line x1="0" y1="464" x2="1024" y2="464"/>
  <line x1="0" y1="480" x2="1024" y2="480"/>
  <line x1="0" y1="496" x2="1024" y2="496"/>
  <line x1="0" y1="512" x2="1024" y2="512"/>
  <line x1="0" y1="528" x2="1024" y2="528"/>
  <line x1="0" y1="544" x2="1024" y2="544"/>
  <line x1="0" y1="560" x2="1024" y2="560"/>
  <line x1="0" y1="576" x2="1024" y2="576"/>
  <line x1="0" y1="592" x2="1024" y2="592"/>
  <line x1="0" y1="608" x2="1024" y2="608"/>
  <line x1="0" y1="624" x2="1024" y2="624"/>
  <line x1="0" y1="640" x2="1024" y2="640"/>
  <line x1="0" y1="656" x2="1024" y2="656"/>
  <line x1="0" y1="672" x2="1024" y2="672"/>
  <line x1="0" y1="688" x2="1024" y2="688"/>
  <line x1="0" y1="704" x2="1024" y2="704"/>
  <line x1="0" y1="720" x2="1024" y2="720"/>
  <line x1="0" y1="736" x2="1024" y2="736"/>
  <line x1="0" y1="752" x2="1024" y2="752"/>
  <line x1="0" y1="768" x2="1024" y2="768"/>
  <line x1="0" y1="784" x2="1024" y2="784"/>
  <line x1="0" y1="800" x2="1024" y2="800"/>
  <line x1="0" y1="816" x2="1024" y2="816"/>
  <line x1="0" y1="832" x2="1024" y2="832"/>
  <line x1="0" y1="848" x2="1024" y2="848"/>
  <line x1="0" y1="864" x2="1024" y2="864"/>
  <line x1="0" y1="880" x2="1024" y2="880"/>
  <line x1="0" y1="896" x2="1024" y2="896"/>
  <line x1="0" y1="912" x2="1024" y2="912"/>
  <line x1="0" y1="928" x2="1024" y2="928"/>
  <line x1="0" y1="944" x2="1024" y2="944"/>
  <line x1="0" y1="960" x2="1024" y2="960"/>
  <line x1="0" y1="976" x2="1024" y2="976"/>
  <line x1="0" y1="992" x2="1024" y2="992"/>
  <line x1="0" y1="1008" x2="1024" y2="1008"/>
  <line x1="0" y1="0" x2="0" y2="1024"/>
  <line x1="16" y1="0" x2="16" y2="1024"/>
  <line x1="32" y1="0" x2="32" y2="1024"/>
  <line x1="48" y1="0" x2="48" y2="1024"/>
  <line x1="64" y1="0" x2="64" y2="1024"/>
  <line x1="80" y1="0" x2="80" y2="1024"/>
  <line x1="96" y1="0" x2="96" y2="1024"/>
  <line x1="112" y1="0" x2="112" y2="1024"/>
  <line x1="128" y1="0" x2="128" y2="1024"/>
  <line x1="144" y1="0" x2="144" y2="1024"/>
  <line x1="160" y1="0" x2="160" y2="1024"/>
  <line x1="176" y1="0" x2="176" y2="1024"/>
  <line x1="192" y1="0" x2="192" y2="1024"/>
  <line x1="208" y1="0" x2="208" y2="1024"/>
  <line x1="224" y1="0" x2="224" y2="1024"/>
  <line x1="240" y1="0" x2="240" y2="1024"/>
  <line x1="256" y1="0" x2="256" y2="1024"/>
  <line x1="272" y1="0" x2="272" y2="1024"/>
  <line x1="288" y1="0" x2="288" y2="1024"/>
  <line x1="304" y1="0" x2="304" y2="1024"/>
  <line x1="320" y1="0" x2="320" y2="1024"/>
  <line x1="336" y1="0" x2="336" y2="1024"/>
  <line x1="352" y1="0" x2="352" y2="1024"/>
  <line x1="368" y1="0" x2="368" y2="1024"/>
  <line x1="384" y1="0" x2="384" y2="1024"/>
  <line x1="400" y1="0" x2="400" y2="1024"/>
  <line x1="416" y1="0" x2="416" y2="1024"/>
  <line x1="432" y1="0" x2="432" y2="1024"/>
  <line x1="448" y1="0" x2="448" y2="1024"/>
  <line x1="464" y1="0" x2="464" y2="1024"/>
  <line x1="480" y1="0" x2="480" y2="1024"/>
  <line x1="496" y1="0" x2="496" y2="1024"/>
  <line x1="512" y1="0" x2="512" y2="1024"/>
  <line x1="528" y1="0" x2="528" y2="1024"/>
  <line x1="544" y1="0" x2="544" y2="1024"/>
  <line x1="560" y1="0" x2="560" y2="1024"/>
  <line x1="576" y1="0" x2="576" y2="1024"/>
  <line x1="592" y1="0" x2="592" y2="1024"/>
  <line x1="608" y1="0" x2="608" y2="1024"/>
  <line x1="624" y1="0" x2="624" y2="1024"/>
  <line x1="640" y1="0" x2="640" y2="1024"/>
  <line x1="656" y1="0" x2="656" y2="1024"/>
  <line x1="672" y1="0" x2="672" y2="1024"/>
  <line x1="688" y1="0" x2="688" y2="1024"/>
  <line x1="704" y1="0" x2="704" y2="1024"/>
  <line x1="720" y1="0" x2="720" y2="1024"/>
  <line x1="736" y1="0" x2="736" y2="1024"/>
  <line x1="752" y1="0" x2="752" y2="1024"/>
  <line x1="768" y1="0" x2="768" y2="1024"/>
  <line x1="784" y1="0" x2="784" y2="1024"/>
  <line x1="800" y1="0" x2="800" y2="1024"/>
  <line x1="816" y1="0" x2="816" y2="1024"/>
  <line x1="832" y1="0" x2="832" y2="1024"/>
  <line x1="848" y1="0" x2="848" y2="1024"/>
  <line x1="864" y1="0" x2="864" y2="1024"/>
  <line x1="880" y1="0" x2="880" y2="1024"/>
  <line x1="896" y1="0" x2="896" y2="1024"/>
  <line x1="912" y1="0" x2="912" y2="1024"/>
  <line x1="928" y1="0" x2="928" y2="1024"/>
  <line x1="944" y1="0" x2="944" y2="1024"/>
  <line x1="960" y1="0" x2="960" y2="1024"/>
  <line x1="976" y1="0" x2="976" y2="1024"/>
  <line x1="992" y1="0" x2="992" y2="1024"/>
  <line x1="1008" y1="0" x2="1008" y2="1024"/>
  </g>
</svg>

<!--
- 64 cells up and down.
- Pick a cell and ask them to find a message that hashes into this cell.
- Talk about the cell in top left.
- What if cell is smaller.
- With a view to explain and understand proof-of-work, we are going to create a game.
-->

---

# Let's invent a new game<span v-if="$clicks<=3"> with hashing</span><span v-if="$clicks>=4">: Mining</span>

<v-clicks>

- With $hash(x) \in [0, 1[$. $hash(x) = 0$, 👎. But $hash(x) \leq 0.00000001$, 👍.
- $\leq 0.01$ ← try 100 times. $\leq 0.0001$ ← try how many times?
- Game: he who finds the message with the smallest hash wins. e.g. $Target = 0.00001$.
- Target: how low? Influence of: player count? player strength? game duration?
- Accept a winner? $hash(winningTicket) \leq target$? Quick, easy.
- 2 winning tickets? Smallest wins.
- Too early win? Next game: target ↘; the hope: duration ↗
- Everyone welcome any time. Joining time matters?
- $target = 10^{-x}$, estimated $10^{x}$ hash attempts. Lots of work!
- Take a guess: what is on the next slide?

</v-clicks>

<!--
- We are designing a game. It has to be enticing to have players want to join.
- It will make sense on the next slide.
- [click] You *"cannot"* find a message that hashes to `0`, but close to `0`, you can.
- This notation will be as if the hash output is between 0 and 1.
- [click] The more tries, the closer to `0`. In the bottom 1%→ ~ 100 tries. And in the bottom 0.01%?
- [click] Name of the game? -> mining. 
- Wins what? To be decided.
- You understand that players have to try many times: bruteforce.
- [click] The more players, the lower the target.
- The stronger the players, the lower the target.
- The longer the desired game duration, the lower the target.
- [click] Winner is eager to publish the message before another one comes.
- It's easy to verify and quick.
- [click] What is the rationale for picking the smallest message that is below target?
- Because it is harder to achieve.
- [click] By how much should the target change? Proportional?
- Change on every game or on average of games? After how many games?
- [click] How important is it to join at start of game? 0 because effort is proportional to potential reward.
- What is impact of new joiners on duration?
- What if players give up? Impact on duration? How do you discover they dropped out?
- [click] Direct correlation.
- [click] What is in the blockchain world with the word _work_?
-->

---

# Why hashes matter for a blockchain: proof of work

My block is heavier than your block. Consensus.

<v-clicks depth="2">

- New game: every block. Block needs a winner.
  - $sha256(block \parallel myKey \parallel nonce) \leq target$; Where $target \in [0, 2^{256}[$
- Game duration: <span v-if="$clicks>=4">10</span> minutes.
- Winnings: block reward.
  - Update the reward? Every 210,000 blocks? $\approx 4$ years
- Target: by protocol.
  - Update frequency? Every 2,016 blocks? $= 2$ weeks
  - current values: [*target*](https://learnmeabitcoin.com/technical/mining/target/), or B? of tries, a.k.a. [*difficulty*](https://www.blockchain.com/explorer/charts/difficulty).
- Here too: eager to prove.
- 2 winning nonces? Fork: take so-called _heaviest_.
- So: $2^{78} \approx 3.10^{23}$ hash attempts per block.
  - The world has proven a lot of **work** was performed.

</v-clicks>

<!--
- Let's apply the mining game to Bitcoin.
- [click] Every block because this is a blockchain.
- It resets on every block.
- [click] Nonce: another name for the magic number that makes it work.
- Why is my key included? To get the winnings.
- [click] What is a good duration value?
- Balance participation, network problems, impatience.
- [click] Block reward amount depends on protocol.
- [click] Halved returns every 210k blocks. -> halving
- How long are 210k blocks? That's 210k _games_.
- at 10 min/block -> 2,100,000 minutes -> 1,458.33 days -> 3.9954 years.
- [click]
- [click] 2,016 blocks -> 20,160 minutes -> 2 weeks.
- [click] Current Bitcoin values.
- Difficulty, could be another multiple of billions.
- [click] 
- [click] Heaviest, another way to say, with more work.
- [click] $19*4+2=78$
- That's a lot of work.
-->

---

# Mining farm

<v-clicks depth="2">

- Throw hardware at hashing.
  - Specialised hardware FTW.
- [Amateur](https://assets.bucket.fourthestate.app/oc-media-prod/content/images/2025/10/ahxyxkt98r1capr8v3o6xuf51zbre923-1024x683.jpg) / [Pro](https://spectrum.ieee.org/media-library/illuminated-cryptocurrency-mining-farm-racks-in-russia.jpg?id=27400476&width=1200&height=900).
- Mining: capital cost, energy cost, output revenue? ⚖️
  - Location arbitrage, economies of scale.
- Small players same chance as large ones. Recent [solo winner](https://coinmarketcap.com/academy/article/bitcoin-solo-miner-wins-dollar210k-despite-near-zero-hashrate). Unattached BTC.
- Decentralisation ethos.

</v-clicks>

<!--
- [click] So many hashes for so much reward incentivises hardware installation.
- [click] History: CPU, GPU, FPGA, ASIC
- [click] Anyone can try.
- [click] The wording is apt.
- [click] Difficult financial balance, arbitrage.
- [click] Large operators have more frequent wins -> easier to justify long term.
- [click] Small players tend to give up, against decentralisation.
-->

---

# Mining pool

<v-clicks depth="2">

- Small players: frequent rewards.
- Objective1 _macro_: $sha256(block \parallel poolKey \parallel nonce) \leq target$
- Prove hashrate?
  - Objective2 _micro_: $sha256(block \parallel poolKey \parallel nonce) \leq playerTarget$
  - Where $target \lll playerTarget$.
  - Frequent reporting of wins in objective2 → earn share of total hashrate.
- Stealing of win is impossible.
- Player still eager to report.
- Next pool win → split by share count, off-chain.
  - Reset players' shares.
  - Withdraw when wanted. Like a bank.
- Downside: re-centralisation, pool operator trust.

</v-clicks>

<!--
- [click] For small players that want more frequent rewards.
- And who cannot justify mining for 10 years for a solo win.
- [click] The pool operator gets the winnings, the small player hashes.
- [click] How do you prove small player is still hashing?
- And avoid slackers.
- [click] Pool has single higher target, or each player has bespoke target.
- [click] How much higher depends on size of mining pool compared to global.
- [click] Player has to keep mining to earn shares of next win.
- Past shares are not deleted. But stay small.
- [click] If player withholds overall win, they lose too. Incentives are aligned.
- [click] If player publishes win alone -> pool operator earns anyway.
- And cannot replace $poolKey$ with $playerKey$ anyway.
- [click] Earned shares are evaluated against the next win.
- Stays on operator's ledger, off-chain, not BTC ledger.
- [click] Next work earns shares for next win.
- [click] Winnings are on operator's key, so works like a bank.
- Player pays transfer costs, and commission.
- [click] Bitoin was created with a goal of decentralising money.
- Mining pools downgrade this promise.
-->

---
layout: iframe
url: https://wall.sli.do/event/aSVqhQPi9sevt3JJANERcC
---
