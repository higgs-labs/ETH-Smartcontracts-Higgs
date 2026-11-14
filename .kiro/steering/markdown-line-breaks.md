---
inclusion: fileMatch
fileMatchPattern: '**/*.md'
---

# Markdown Line Break Convention

When writing or editing Markdown files, do not break to the next line unnecessarily.

- Keep each paragraph on a single line. Do not insert hard line breaks (manual newlines) to wrap text at an arbitrary column width. Let the text flow and rely on the editor or renderer to soft-wrap.
- Only start a new line when it is semantically meaningful, for example:
  - Between distinct paragraphs (separated by a blank line).
  - For list items, headings, code blocks, blockquotes, and table rows.
  - Where the Markdown syntax genuinely requires it.
- Do not add trailing spaces or backslashes to force line breaks within a paragraph.
- Avoid splitting a single sentence across multiple lines.

# Folder listing

When exhibiting a folder structure, use the `tree` format, which looks like this:

```
counter-project/
├── src/            # contracts
├── lib/            # dependencies
├── test/           # tests
├── script/         # deploy scripts
├── foundry.toml    # config
└── out/            # build artifacts: ABI + bytecode
```