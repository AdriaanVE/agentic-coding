# Example CLAUDE.md and AGENTS.md

These example files belong in the root of your code repository.

## CLAUDE.md

Picked up by Claude Code. Use it to reference `AGENTS.md` and any global rules. Keep it minimal — put the actual project context in `AGENTS.md`.

## AGENTS.md

Picked up by Claude Code, Codex, and other AI coding tools. This is where you describe your project so that AI assistants have the context they need.

### What to include

- **Project overview** — What the project does, in one or two lines
- **Tech stack** — Language, framework, database, etc.
- **Commands** — How to run tests (`pytest`), linting (`pre-commit`), builds, benchmarks
- **Architecture** — Key directories and what they contain
- **Conventions** — Naming patterns, test structure, schema approach
- **Environment** — How to set up locally (env vars, docker, dependencies)
- **Dependencies** — Internal/external libraries the project relies on

### Subdirectories

You can also place `AGENTS.md` files in subdirectories for module-specific context (e.g. `billing_agent/AGENTS.md`).

## Other tools

`AGENTS.md` is a convention shared across multiple AI coding tools. Other tools use their own files for similar purposes:

- **Cursor** — `.cursorrules`
- **GitHub Copilot** — `.github/copilot-instructions.md`
- **Codex** — `AGENTS.md` (same convention)
