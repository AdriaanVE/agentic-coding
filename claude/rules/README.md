# Rules

Behavioral guidelines for LLM coding assistants, inspired by [observations by Karpathy](https://github.com/forrestchang/andrej-karpathy-skills?tab=readme-ov-file) with additional custom rules.

These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Rules overview

| # | Rule | Summary |
|---|------|---------|
| 1 | Never start editing code without permission | Analyze and explain before touching code |
| 2 | Think Before Coding | Surface assumptions, tradeoffs, and confusion |
| 3 | Simplicity First | Minimum code that solves the problem |
| 4 | Surgical Changes | Touch only what you must |
| 5 | Goal-Driven Execution | Define success criteria, loop until verified |
| 6 | Challenge, Don't Comply Blindly | Be honest, not agreeable |

## Usage

Add this line to your `CLAUDE.md` or `AGENTS.md`:

```markdown
Follow the rules in @/path/to/RULES.md
```

For global use, place `RULES.md` in `~/.claude/RULES.md` and reference it from `~/.claude/CLAUDE.md`.
