# Agentic Coding

Reusable configurations for AI-assisted coding workflows.

## Contents

### `claude/skills/`

Custom skills for Claude Code.

- **ask-codex** — Delegate tasks to OpenAI Codex asynchronously. Run code reviews, ask questions, or launch implementation tasks in the background while continuing your conversation.
- **ask-claude** — Delegate tasks to a separate Claude Code instance asynchronously. Runs `claude -p` with `stream-json` output in the background for crash-resilient JSONL capture. Designed for **OpenCode** (includes `.opencode/opencode.json` permissions); Claude Code users can use the built-in Task tool instead.
  > **Note:** This skill is configured for **Azure Foundry** deployments — it sources `~/dotenvs/claude.env` to set `CLAUDE_CODE_USE_FOUNDRY`, `ANTHROPIC_FOUNDRY_RESOURCE`, and the API key. If you use a **direct Anthropic API key**, remove the `source ~/dotenvs/claude.env 2>/dev/null` line from the SKILL.md examples; `claude -p` will use your existing auth automatically.

### `claude/commands/`

Custom slash commands for Claude Code.

- **git-add-commit** — Safe git commit workflow: checks branch, runs pre-commit hooks, generates a commit message, and optionally pushes.
- **review-mr** — Review a merge request branch by diffing against `origin/main` and invoking a code-reviewer subagent.

### `claude/rules/`

- **RULES.md** — Behavioral guidelines for LLM coding assistants, inspired by [observations by Karpathy](https://github.com/forrestchang/andrej-karpathy-skills?tab=readme-ov-file) with additional custom rules. Biases toward caution, surgical changes, simplicity, and honest pushback.

### `hooks/`

- **permission-evaluator** — AI-powered PermissionRequest hook that calls Sonnet via Azure Foundry to auto-approve safe tool calls and warn on dangerous ones. Includes a settings snippet and setup instructions.

## Usage

### Where files should live

| File | Location | Scope |
|------|----------|-------|
| `RULES.md` | `~/.claude/RULES.md` | Global — applies to all projects |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` (global) or repo root (project) | Global or per-project instructions for Claude Code |
| `AGENTS.md` | Repo root (or subdirectories) | Per-project / per-module instructions for AI agents |
| Hook scripts | `~/.claude/hooks/` | Global — hooks that run on Claude Code events |

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

## Compatibility

These configs are designed for **Claude Code** but are largely compatible with **[OpenCode](https://opencode.ai/)**:

- **`AGENTS.md`** — Shared convention, works in both tools
- **Skills** — OpenCode discovers skills from `.claude/skills/` directly. YAML frontmatter (`name`, `description`) is included for OpenCode compatibility; Claude Code ignores it.
- **Commands** — Place in `.opencode/commands/` for OpenCode (same markdown format)

For other tools, see [`examples/README.md`](examples/README.md).
