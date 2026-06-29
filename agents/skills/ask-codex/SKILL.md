---
name: ask-codex
description: Delegate tasks to OpenAI Codex asynchronously in the background
---

# Claude Code Skill: Ask Codex

Delegate a task to OpenAI Codex asynchronously. Codex runs in the background while the main conversation continues.

---

## When to use

Trigger phrases: "ask codex", "ask-codex", "/ask-codex"

Use this skill when the user wants to delegate a task to Codex, get a second opinion from Codex, or run Codex side-by-side for comparison.

## Prerequisites

- `codex` CLI must be installed and authenticated

## Arguments

Free-form string describing what Codex should do. If empty, ask the user.

---

## Execution order

**IMPORTANT: Always launch Codex FIRST, before starting your own work.** Codex runs in the background and takes time. If you are reviewing code, researching, or doing any parallel task, fire off the Codex command immediately, then proceed with your own analysis while Codex works. Do not do your own work first and ask Codex second.

---

## Steps

### 1. Determine the Codex command

Always use `codex exec` subcommands with `--json`. These are non-interactive and produce structured JSONL output that pipes reliably. Never use the base `codex "<prompt>"` command — it launches an interactive TUI that hangs in background scripts.

**Always pass `--cd <repo_path>`** with the absolute path to the target repository. Do not rely on inherited Bash cwd. This ensures Codex operates on the correct repo and picks up the right `.codex/config.toml` and project rules. Use `pwd` in a foreground Bash call to resolve the path if needed.

| User intent | Command |
|---|---|
| Review branch changes | `codex exec --cd <repo> review --base <branch> --json` |
| Review a specific commit | `codex exec --cd <repo> review --commit <sha> --json` |
| Review uncommitted changes | `codex exec --cd <repo> review --uncommitted --json` |
| General task / question | `codex exec --cd <repo> --json "<prompt>"` |

Default base branch for reviews: detect with `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`, falling back to `main`. If uncertain, ask the user.

### 2. Launch as a background Bash command

Run the codex command directly with `run_in_background: true` and `timeout: 360000`. No tmux needed — `codex exec` is non-interactive and the background task notifies on completion.

**You MUST create a unique output file path before launching Codex** to avoid data races when multiple Codex runs overlap. Allocate the path in a separate **foreground** Bash call using `mktemp`:

```bash
mktemp /tmp/codex-output-XXXXXXXXXX
```

Store the returned absolute path (e.g. `/tmp/codex-output-a8K31pQz9L`) in your conversation context. From this point on, use the **literal path** in all subsequent Bash calls. Do not rely on shell variables like `$CODEX_OUT` surviving across calls.

**Never reuse a hardcoded filename.** Always allocate a fresh path with `mktemp`.

Redirect both stdout and stderr to the output file. Codex prints its session banner to stderr; without `2>&1` you lose it and get confusing split output.

If the working directory is **not a git repo**, add `--skip-git-repo-check` to the command.

```bash
# run_in_background: true
# timeout: 360000

codex exec --cd /path/to/repo review --base main --json > /tmp/codex-output-a8K31pQz9L 2>&1
```

**Do not clean up the output file inside this script.** The file is needed for step 4.

### 3. Inform the user and continue

Tell the user Codex is running and the conversation can continue:

> "Codex is working on that in the background. I'll share the results when it's done — we can keep going in the meantime."

**CRITICAL: Do NOT touch the output file until the completion notification arrives.** Do not read it, do not parse it, do not delete it, do not draw conclusions from partial contents. Codex writes results incrementally; the `agent_message` (the actual answer) is emitted last. Reading early will show only `command_execution` items, which looks like Codex produced no answer, tempting you to clean up and re-run. Wait for the notification.

### 4. Collect and parse results

When the background task completes (you'll be notified via task completion notification), read the output file using the literal path allocated before launch. Do not try to reconstruct it from shell variables, PID, timestamp, or task output. If notifications are unavailable, poll with `TaskOutput` using `block: false`.

The JSONL contains one JSON object per line. Key event types:

| `type` | What it contains | Action |
|---|---|---|
| `item.completed` with `"type":"agent_message"` | **The final answer.** The `text` field has the review or response. | Present to user. |
| `item.completed` with `"type":"reasoning"` | Codex's thinking traces. | Skip unless user asks. |
| `item.completed` with `"type":"command_execution"` | Tool calls (file reads, git commands). | Skip unless user asks. |
| `error` | Errors or reconnections (e.g. `"stream disconnected"`). | Note if the final answer is missing; Codex may have recovered and continued. |

**Parsing approach:**

JSONL lines can be malformed (extra data, empty lines, stderr mixed in). Always wrap `json.loads` in a try/except per line and skip unparseable lines:

```python
import json
results = []
with open(output_path) as f:
    for line in f:
        try:
            obj = json.loads(line.strip())
        except (json.JSONDecodeError, ValueError):
            continue
        if obj.get('type') == 'item.completed' and obj.get('item', {}).get('type') == 'agent_message':
            results.append(obj['item']['text'])
final_answer = results[-1] if results else None
```

Key details:
- The final answer is in `item.text` (not `item.content[].output_text`)
- Use the **last** `agent_message` (Codex may emit multiple during streaming)
- If no `agent_message` found, check for `error` events and report what happened
- If the task failed and the output indicates codex was not found, run `which codex` to diagnose and inform the user

### 5. Clean up

After presenting results, remove the output file using the same literal path:

```bash
rm -f /tmp/codex-output-a8K31pQz9L
```

---

## Examples

### Code review of a branch

User: "Ask Codex to review this branch"

```bash
# Step 1: Foreground — allocate unique output path
mktemp /tmp/codex-output-XXXXXXXXXX
# Returns e.g.: /tmp/codex-output-a8K31pQz9L
```

```bash
# Step 2: Background — launch Codex using the literal path
# run_in_background: true, timeout: 360000
codex exec --cd /Users/me/Code/my-project review --base main --json > /tmp/codex-output-a8K31pQz9L 2>&1
```

Then: inform user, wait for notification, Read the literal path, extract the last `agent_message`, present findings, clean up with `rm -f`.

### General question

User: "Ask Codex to explain the router architecture"

```bash
mktemp /tmp/codex-output-XXXXXXXXXX
# Returns: /tmp/codex-output-xQ7r2mN4pB
```

```bash
# run_in_background: true, timeout: 360000
codex exec --cd /Users/me/Code/my-project --json "Explain the router architecture in this codebase." > /tmp/codex-output-xQ7r2mN4pB 2>&1
```

### Implementation task

User: "Have Codex add input validation to the router"

```bash
mktemp /tmp/codex-output-XXXXXXXXXX
# Returns: /tmp/codex-output-kL9w3vR5tJ
```

```bash
# run_in_background: true, timeout: 360000
codex exec --cd /Users/me/Code/my-project --json "Add input validation to the router node." > /tmp/codex-output-kL9w3vR5tJ 2>&1
```
