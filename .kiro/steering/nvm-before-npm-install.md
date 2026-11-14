---
inclusion: always
---

# Node Version Before Installing Dependencies

Always run `nvm use` before any `npm install`. This ensures the Node version pinned in `.nvmrc` is active so dependencies are installed against the correct runtime.

- Run the two commands together: `nvm use && npm install`.
- This applies to every form of the install command, including `npm install <package>`, `npm ci`, and `npm i`.
- If `nvm use` reports the required version is not installed, run `nvm install` first, then retry.
