# Agentic Coding

Reusable configurations for AI-assisted coding workflows.

## Contents

### `claude/skills/`

Custom skills for Claude Code.

- **ask-codex** — Delegate tasks to OpenAI Codex asynchronously. Run code reviews, ask questions, or launch implementation tasks in the background while continuing your conversation.

### `claude/commands/`

Custom slash commands for Claude Code.

- **git-add-commit** — Safe git commit workflow: checks branch, runs pre-commit hooks, generates a commit message, and optionally pushes.
- **review-mr** — Review a merge request branch by diffing against `origin/main` and invoking a code-reviewer subagent.

### `claude/rules/`

- **RULES.md** — Behavioral guidelines for LLM coding assistants, based on [observations by Karpathy](https://github.com/forrestchang/andrej-karpathy-skills?tab=readme-ov-file). Biases toward caution, surgical changes, and simplicity.

## Usage

### Where files should live

| File | Location | Scope |
|------|----------|-------|
| `RULES.md` | `~/.claude/RULES.md` | Global — applies to all projects |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` (global) or repo root (project) | Global or per-project instructions for Claude Code |
| `AGENTS.md` | Repo root (or subdirectories) | Per-project / per-module instructions for AI agents |

- **`~/.claude/`** — Files here are picked up globally across all projects.
- **Repo root** — `CLAUDE.md` and `AGENTS.md` placed here apply to that specific repository.
- **Subdirectories** — `AGENTS.md` can also be placed in subdirectories for module-specific instructions.

### Referencing the rules

Add this line to your project's `CLAUDE.md` or `AGENTS.md`:

```markdown
Follow the rules in @/path/to/RULES.md
```

See [`examples/`](examples/) for full examples of `CLAUDE.md` and `AGENTS.md` files.

> **Note:** These configurations are starting points. Discuss them with your AI coding assistant and tailor them to your personal workflow and preferences.
