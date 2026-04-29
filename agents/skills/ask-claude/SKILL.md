---
name: ask-claude
description: Delegate tasks to a separate Claude Code instance asynchronously in the background
---

# Codex Skill: Ask Claude

Delegate a task to a separate Claude Code instance asynchronously. Claude runs in the background while the main conversation continues.

---

## When to use

Trigger phrases: "ask claude", "ask-claude", "/ask-claude"

Use this skill when the user wants to delegate a task to Claude, get a second opinion from Claude, or run Claude side by side for comparison.

## Prerequisites

- `claude` CLI must be installed and authenticated

## Arguments

Free-form string describing what Claude should do. If empty, ask the user.

---

## Execution order

**IMPORTANT: Always launch Claude FIRST, before starting your own work.** Claude runs in the background and takes time. If you are reviewing code, researching, or doing any parallel task, fire off the Claude command immediately, then proceed with your own analysis while Claude works. Do not do your own work first and ask Claude second.

---

## Steps

### 1. Determine the Claude command

Always use `claude -p` (print mode) for non-interactive execution. Required flags:

| Flag | Purpose |
|---|---|
| `-p` | Non-interactive print mode (required) |
| `--output-format stream-json` | JSONL streaming output for crash resilience |
| `--verbose` | Required when using `stream-json` |
| `--no-session-persistence` | Do not save the child session to disk |

Claude Code does not expose a `--cd` or `--cwd` flag equivalent to `codex exec --cd`. Launch the background Bash command with the target repository as the command working directory. Do not rely on telling Claude to `cd` in the prompt.

Use `--add-dir <path>` only when Claude needs access to additional directories beyond the primary working directory. `--add-dir` grants extra tool access; it does not set the primary working directory.

| User intent | Command |
|---|---|
| General task / question | `claude -p --output-format stream-json --verbose --no-session-persistence "<prompt>"` |
| Task with specific model | Add `--model <model>` (e.g. `--model sonnet`) |
| Task needing another directory | Add `--add-dir <path>` for each extra directory |

### 2. Launch as a long-running Bash command

Run the Claude command directly as a long-running shell command. No tmux needed. `claude -p` is non-interactive. Run the `claude -p` command with `sandbox_permissions: "require_escalated"` because Claude Code needs outbound API/socket access. Without escalation, Codex sandboxing can fail with `FailedToOpenSocket`. If the command is still running when the shell tool returns, keep the returned session id and continue the conversation while polling that session for completion.

**You MUST create a unique output file path before launching Claude** to avoid data races when multiple Claude runs overlap. Allocate the path in a separate **foreground** Bash call using `mktemp`:

```bash
mktemp /tmp/claude-output-XXXXXXXXXX
```

Store the returned absolute path (e.g. `/tmp/claude-output-a8K31pQz9L`) in your conversation context. From this point on, use the **literal path** in all subsequent Bash calls. Do not rely on shell variables surviving across calls.

**Never reuse a hardcoded filename.** Always allocate a fresh path with `mktemp`.

Redirect both stdout and stderr to the output file. Claude may print diagnostics to stderr; without `2>&1` you can lose useful failure information.

```bash
# long-running shell command
# sandbox_permissions: require_escalated
# keep the returned session id if the command is still running

claude -p --output-format stream-json --verbose --no-session-persistence "<prompt>" > /tmp/claude-output-a8K31pQz9L 2>&1
```

**Do not clean up the output file inside this script.** The file is needed for step 4.

### 3. Inform the user and continue

Tell the user Claude is running and the conversation can continue:

> "Claude is working on that in the background. I'll share the results when it's done, and we can keep going in the meantime."

### 4. Collect and parse results

When the shell session completes, read the output file using the literal path allocated before launch. Do not try to reconstruct it from shell variables, PID, timestamp, or task output.

The JSONL contains one JSON object per line. Key event types:

| `type` | What it contains | Action |
|---|---|---|
| `system` with `subtype: "init"` | Session initialization (model, tools, session_id). | Skip unless user asks. |
| `assistant` | The assistant's response. Content is in the `message.content[]` array. | Extract text if no `result` line exists. |
| `result` with `subtype: "success"` | **The final answer.** The `result` field has the complete response text. Also contains `total_cost_usd` and `usage`. | Present to user. |
| `result` with `subtype: "error"` | An error occurred. | Report to user. |

**Parsing approach:**
1. Look for a line containing `"type":"result"`.
2. If found with `subtype: "success"`, extract the `result` field and present it.
3. If no `result` line exists, find all lines containing `"type":"assistant"`. Use the **last** one and extract text from `message.content[].text`.
4. If nothing useful is found, report the raw output or error.
5. If the output indicates `claude` was not found, run `which claude` to diagnose and inform the user.

Optionally report `total_cost_usd` from the result line so the user sees cost.

### 5. Clean up

After presenting results, remove the output file using the same literal path:

```bash
rm -f /tmp/claude-output-a8K31pQz9L
```

---

## Examples

### General question

User: "Ask Claude to explain the router architecture"

```bash
# Step 1: Foreground, allocate unique output path
mktemp /tmp/claude-output-XXXXXXXXXX
# Returns e.g.: /tmp/claude-output-a8K31pQz9L
```

```bash
# Step 2: Long-running command, launch Claude from the target repository working directory
# sandbox_permissions: require_escalated
# keep the returned session id if the command is still running
claude -p --output-format stream-json --verbose --no-session-persistence \
  "Explain the router architecture in this codebase." \
  > /tmp/claude-output-a8K31pQz9L 2>&1
```

Then: inform user, poll the running session until it exits, read the literal path, extract the `result` field, present findings, clean up with `rm -f`.

### Code review of uncommitted changes

User: "Ask Claude to review my uncommitted changes"

```bash
mktemp /tmp/claude-output-XXXXXXXXXX
# Returns: /tmp/claude-output-xQ7r2mN4pB
```

```bash
# long-running shell command
# sandbox_permissions: require_escalated
# keep the returned session id if the command is still running
claude -p --output-format stream-json --verbose --no-session-persistence \
  "Review the uncommitted changes in this repository and provide findings first." \
  > /tmp/claude-output-xQ7r2mN4pB 2>&1
```

### Task with an additional directory

User: "Ask Claude to compare this app with the shared library"

```bash
mktemp /tmp/claude-output-XXXXXXXXXX
# Returns: /tmp/claude-output-kL9w3vR5tJ
```

```bash
# long-running shell command
# sandbox_permissions: require_escalated
# keep the returned session id if the command is still running
claude -p --add-dir /Users/me/Code/shared-library \
  --output-format stream-json --verbose --no-session-persistence \
  "Compare this app's auth flow with the shared library auth helpers." \
  > /tmp/claude-output-kL9w3vR5tJ 2>&1
```

### Implementation task with specific model

User: "Have Claude add input validation using sonnet"

```bash
mktemp /tmp/claude-output-XXXXXXXXXX
# Returns: /tmp/claude-output-pN4sR8xYz2
```

```bash
# long-running shell command
# sandbox_permissions: require_escalated
# keep the returned session id if the command is still running
claude -p --output-format stream-json --verbose --no-session-persistence \
  --model sonnet \
  "Add input validation to the router node." \
  > /tmp/claude-output-pN4sR8xYz2 2>&1
```
