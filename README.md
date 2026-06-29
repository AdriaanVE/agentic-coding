# Agentic Coding

Reusable configurations for AI-assisted coding workflows.

## Contents

### `agents/skills/`

Custom skills for AI coding agents.

- **ask-codex**: Delegate tasks to OpenAI Codex asynchronously. Run code reviews, ask questions, or launch implementation tasks in the background while continuing your conversation.
- **ask-claude**: Delegate tasks to a separate Claude Code instance asynchronously. Runs `claude -p` with `stream-json` output in the background for crash-resilient JSONL capture. Designed for Codex users who want a headless Claude sidecar.
- **brain**: Interact with a personal Obsidian knowledge base (`~/Brain`). Look up, create, and update notes using vault conventions and templates.
- **jira-ticket**: Draft the body text of a Jira ticket from provided context, following a fixed user-story layout (Title / As a / I would like / In order to / Context / Acceptance Criteria / Blocked by). Outputs copy-paste text only.
- **preview**: Send files or diffs to a tmux preview pane. Automatically shows `git diff` after edits and renders `.md`, `.docx`, `.xlsx`, `.pdf`, `.pptx` files. See [`tmux-preview/`](tmux-productivity-hacks/tmux-preview/) for the full setup.
- **review-pr**: Review pull requests or merge requests with a structured, diff-focused workflow.
- **socratic-spec-interview**: Turn rough feature ideas into clearer implementation specs through a Socratic interview flow.

### `tmux-productivity-hacks/`

tmux-based workflow scripts for project navigation and AI-assisted development.

#### `tmux-preview/`

A tmux workflow that pairs Claude Code with a live preview pane. Claude works on the left, diffs and document previews render on the right. Includes the `tmux-claude-preview` launcher, a `preview` script (markitdown + glow), keyboard shortcuts, and auto-allow permission patterns. See the [tmux-preview README](tmux-productivity-hacks/tmux-preview/README.md) for details.

#### `tmux-fuzzyfind/`

Fuzzy-find a project directory with `fzf` and open it in a dedicated tmux session. If the session already exists, it switches to it. Inspired by [ThePrimeagen's tmux-sessionizer](https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer). See the [tmux-fuzzyfind README](tmux-productivity-hacks/tmux-fuzzyfind/README.md) for details.

![fzf project picker in tmux-sessionizer](tmux-productivity-hacks/tmux-fuzzyfind/screenshot.png)

The sub-README covers dependencies, installation, configuration, keybindings, and macOS terminal compatibility.

### `agents/commands/`

Custom slash commands for Claude Code.

- **git-add-commit**: Safe git commit workflow: checks branch, runs pre-commit hooks, generates a commit message, and optionally pushes.
- **open-vscode**: Open the current project in Visual Studio Code.
- **review-mr**: Review a merge request branch by diffing against `origin/main` and invoking a code-reviewer subagent.

### `agents/rules/`

- **RULES.md**: Behavioral guidelines for LLM coding assistants, inspired by [observations by Karpathy](https://github.com/forrestchang/andrej-karpathy-skills?tab=readme-ov-file) with additional custom rules. Biases toward caution, surgical changes, simplicity, and honest pushback.

### `hooks/`

- **permission-evaluator**: AI-powered PermissionRequest hook that calls Sonnet via Azure Foundry to auto-approve safe tool calls and warn on dangerous ones. Includes a settings snippet and setup instructions.

## Usage

### Installing skills

Skills live in `agents/skills/`. Install only the skills you need.

| Agent | Skill directory |
|-------|-----------------|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.codex/skills/` |
| OpenCode | `.claude/skills/` in the project |

Copy a skill when you want a stable snapshot:

```bash
mkdir -p ~/.codex/skills
cp -R agents/skills/ask-claude ~/.codex/skills/
```

Symlink a skill when you want edits in this repo to apply immediately:

```bash
mkdir -p ~/.codex/skills
ln -s "$PWD/agents/skills/ask-claude" ~/.codex/skills/ask-claude
```

Install all skills only if you want the full set available:

```bash
mkdir -p ~/.codex/skills
cp -R agents/skills/* ~/.codex/skills/
```

### Where files should live

| File | Location | Scope |
|------|----------|-------|
| `RULES.md` | `~/.claude/RULES.md` | Global, applies to all projects |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` (global) or repo root (project) | Global or per-project instructions for Claude Code |
| `AGENTS.md` | Repo root (or subdirectories) | Per-project / per-module instructions for AI agents |
| Hook scripts | `~/.claude/hooks/` | Global hooks that run on Claude Code events |

- **`~/.claude/`**: Files here are picked up globally across all projects.
- **Repo root**: `CLAUDE.md` and `AGENTS.md` placed here apply to that specific repository.
- **Subdirectories**: `AGENTS.md` can also be placed in subdirectories for module-specific instructions.

### Referencing the rules

Add this line to your project's `CLAUDE.md` or `AGENTS.md`:

```markdown
Follow the rules in @/path/to/RULES.md
```

See [`examples/`](examples/) for full examples of `CLAUDE.md` and `AGENTS.md` files.

> **Note:** These configurations are starting points. Discuss them with your AI coding assistant and tailor them to your personal workflow and preferences.

## Compatibility

These configs are designed for **Claude Code** but are largely compatible with **[OpenCode](https://opencode.ai/)**:

- **`AGENTS.md`**: Shared convention, works in both tools
- **Skills**: OpenCode discovers skills from `.claude/skills/` directly. YAML frontmatter (`name`, `description`) is included for OpenCode compatibility; Claude Code ignores it. In this repo, skills live under `agents/skills/`, symlink or copy to `.claude/skills/` as needed.
- **Commands**: Place in `.opencode/commands/` for OpenCode (same markdown format)

For other tools, see [`examples/README.md`](examples/README.md).
