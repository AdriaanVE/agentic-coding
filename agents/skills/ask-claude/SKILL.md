---
name: ask-claude
description: Delegate tasks to a separate Claude Code instance asynchronously in the background
---

# Claude Code Skill: Ask Claude

Delegate a task to a separate Claude Code instance asynchronously. The child Claude runs in the background while the main conversation continues.

---

## When to use

Trigger phrases: "ask claude", "ask-claude", "/ask-claude"

Use this skill when the user wants to delegate a task to a second Claude instance, get a second opinion, or run Claude side-by-side on a different task.

## Prerequisites

- `claude` CLI must be installed and on PATH
- `~/dotenvs/claude.env` must exist with Foundry credentials

## Arguments

Free-form string describing what Claude should do. If empty, ask the user.

---

## Steps

### 1. Determine the Claude command

Always use `claude -p` (print mode) for non-interactive execution. Required flags:

| Flag | Purpose |
|---|---|
| `-p` | Non-interactive print mode (required) |
| `--output-format stream-json` | JSONL streaming output for crash resilience |
| `--verbose` | Required when using `stream-json` |
| `--no-session-persistence` | Don't save the child session to disk |

| User intent | Command |
|---|---|
| General task / question | `claude -p --output-format stream-json --verbose --no-session-persistence "<prompt>"` |
| Task with specific model | Add `--model <model>` (e.g. `--model sonnet`) |

### 2. Launch as a background Bash command

Run with `run_in_background: true` and `timeout: 360000`.

**You MUST create a unique output file** for each invocation to avoid data races. Use epoch seconds + PID:

```bash
CLAUDE_OUT="/tmp/claude-output-$(date +%s)-$$.jsonl"
```

**Never reuse a hardcoded filename.** Always generate a fresh unique path.

**Critical:** You must source the Foundry env vars so the child process can authenticate.

```bash
# run_in_background: true
# timeout: 360000

CLAUDE_OUT="/tmp/claude-output-$(date +%s)-$$.jsonl"
source ~/dotenvs/claude.env 2>/dev/null
claude -p --output-format stream-json --verbose --no-session-persistence "<prompt>" > "$CLAUDE_OUT" 2>&1
```

**Do not clean up the output file inside this script.** The file is needed for step 4.

### 3. Inform the user and continue

Tell the user Claude is running and the conversation can continue:

> "Claude is working on that in the background. I'll share the results when it's done — we can keep going in the meantime."

### 4. Collect and parse results

When the background task completes (you'll be notified via task completion notification), read the output file.

The JSONL contains one JSON object per line (plus a possible echo line from sourcing the env). Key event types:

| `type` | What it contains | Action |
|---|---|---|
| `system` with `subtype: "init"` | Session initialization (model, tools, session_id). | Skip unless user asks. |
| `assistant` | The assistant's response. Content is in `message.content[]` array — look for items with `type: "text"`. | Extract text if no `result` line exists. |
| `result` with `subtype: "success"` | **The final answer.** The `result` field has the complete response text. Also contains `total_cost_usd` and `usage`. | Present to user. |
| `result` with `subtype: "error"` | An error occurred. | Report to user. |

**Parsing approach:**
1. Look for a line containing `"type":"result"` — this is the final answer (in the `.result` field)
2. If found with `subtype: "success"`, extract the `result` field and present it
3. If no `result` line exists (crash), find all lines containing `"type":"assistant"` — use the **last** one and extract text from `message.content[].text`
4. If nothing useful found, report the raw output or error
5. If the output indicates claude was not found, run `which claude` to diagnose

Optionally report `total_cost_usd` from the result line so the user sees cost.

### 5. Clean up

After presenting results:

```bash
rm -f "$CLAUDE_OUT"
```

---

## Examples

### General question

User: "Ask Claude to explain the router architecture"

```bash
CLAUDE_OUT="/tmp/claude-output-$(date +%s)-$$.jsonl"
source ~/dotenvs/claude.env 2>/dev/null
claude -p --output-format stream-json --verbose --no-session-persistence \
  "Explain the router architecture in this codebase." \
  > "$CLAUDE_OUT" 2>&1
```

### Code review of uncommitted changes

User: "Ask Claude to review my uncommitted changes"

```bash
CLAUDE_OUT="/tmp/claude-output-$(date +%s)-$$.jsonl"
source ~/dotenvs/claude.env 2>/dev/null
DIFF=$(git diff)
claude -p --output-format stream-json --verbose --no-session-persistence \
  "Review these uncommitted changes and provide feedback:\n\n$DIFF" \
  > "$CLAUDE_OUT" 2>&1
```

### Implementation task with specific model

User: "Have Claude add input validation using sonnet"

```bash
CLAUDE_OUT="/tmp/claude-output-$(date +%s)-$$.jsonl"
source ~/dotenvs/claude.env 2>/dev/null
claude -p --output-format stream-json --verbose --no-session-persistence \
  --model sonnet \
  "Add input validation to the router node." \
  > "$CLAUDE_OUT" 2>&1
```
