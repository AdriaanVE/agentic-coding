---
name: chub
description: >-
  Use Context Hub (chub) CLI to search and retrieve up-to-date,
  LLM-optimized documentation for APIs, SDKs, and services.
  Ensures answers reference the latest endpoints, parameters,
  and authentication patterns instead of relying on potentially
  stale training data.
metadata:
  when_to_use: >-
    TRIGGER when: the user mentions "API" or "api", references a
    specific service API or SDK (e.g. Stripe API, Notion API),
    encounters deprecated endpoints or outdated SDK methods,
    asks about the latest version of an API, or troubleshoots
    errors that suggest an endpoint has changed (404s on known
    routes, removed fields, changed auth flows).
    DO NOT TRIGGER when: the term "API" appears only in the
    context of designing a new internal API or discussing API
    design principles with no need for external documentation.
---

# chub — Context Hub CLI

Look up the latest API and SDK documentation via `chub` before
answering questions about external APIs. This prevents answers
based on outdated training data.

## When to use this skill

- User mentions an **API** or **SDK** by name
- User asks how to call a specific **endpoint**
- Code references a **deprecated** or **removed** endpoint
- Errors suggest an **outdated** API version (404, unknown field, changed auth)
- User asks about the **latest version** of an API or SDK
- User wants to compare **old vs new** API behavior

## Quick reference

```bash
# Refresh the local registry index
chub update

# Search for docs (returns IDs, type, languages, description)
chub search "<query>"
chub search "<query>" --tags <tags> --lang <language> --limit <n>

# Fetch documentation by ID (auto-detects doc vs skill)
chub get <id>
chub get <id> --lang py          # language variant
chub get <id> --version 2024-11  # specific API version
chub get <id> --full             # all files, not just entry point
chub get <id> --file refs/auth.md  # specific reference file

# Rate a doc (helps improve the registry)
chub feedback <id> up "useful"
chub feedback <id> down "outdated examples" --label outdated

# Annotate a doc with agent notes
chub annotate <id> "requires API key in X-Api-Key header"
```

## Workflow

1. **Search** — run `chub search "<api or service name>"` to find
   matching docs. Use `--lang` if the user works in a specific language.
2. **Fetch** — run `chub get <id>` for the top match. Add `--full`
   when the entry point alone is insufficient.
3. **Answer** — use the fetched documentation to provide an accurate,
   up-to-date response. Cite the chub doc ID so the user can fetch
   it themselves.
4. **Flag staleness** — if the fetched doc looks outdated, tell the
   user and run `chub feedback <id> down "outdated" --label outdated`.

## Handling deprecation and version issues

When the user hits a deprecation or version mismatch:

1. Search for the service: `chub search "<service>"`
2. Fetch the doc and check for version/migration notes
3. If a `--version` flag is available, compare old vs current
4. Summarize what changed and provide the updated code

## Examples

```bash
# User asks about Stripe payment intents
chub search "stripe"
chub get stripe/api --lang py

# User gets 404 on a Notion endpoint
chub search "notion"
chub get notion/workspace-api --lang py --full

# User wants latest Claude API patterns
chub search "claude"
chub get anthropic/claude-api --lang py
```
