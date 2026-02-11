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

## Steps

### 1. Determine the Codex command

Always use `codex exec` subcommands with `--json`. These are non-interactive and produce structured JSONL output that pipes reliably. Never use the base `codex "<prompt>"` command — it launches an interactive TUI that hangs in background scripts.

| User intent | Command |
|---|---|
| Review branch changes | `codex exec review --base <branch> --json` |
| Review a specific commit | `codex exec review --commit <sha> --json` |
| Review uncommitted changes | `codex exec review --uncommitted --json` |
| General task / question | `codex exec --json "<prompt>"` |

Default base branch for reviews: detect with `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`, falling back to `main`. If uncertain, ask the user.

### 2. Launch as a background Bash command

Run the codex command directly with `run_in_background: true` and `timeout: 360000`. No tmux needed — `codex exec` is non-interactive and the background task notifies on completion.

**Use a unique output file** to avoid data races when multiple Codex runs overlap. Generate one with `mktemp`:

```bash
CODEX_OUT=$(mktemp /tmp/codex-output-XXXXXX.jsonl)
```

Redirect both stdout and stderr to the output file. Codex prints its session banner to stderr; without `2>&1` you lose it and get confusing split output.

If the working directory is **not a git repo**, add `--skip-git-repo-check` to the command.

```bash
# run_in_background: true
# timeout: 360000

codex exec review --base main --json > "$CODEX_OUT" 2>&1
```

**Do not clean up the output file inside this script.** The file is needed for step 4.

### 3. Inform the user and continue

Tell the user Codex is running and the conversation can continue:

> "Codex is working on that in the background. I'll share the results when it's done — we can keep going in the meantime."

### 4. Collect and parse results

When the background task completes (you'll be notified via task completion notification), read the output file. If notifications are unavailable, poll with `TaskOutput` using `block: false`.

The JSONL contains one JSON object per line. Key event types:

| `type` | What it contains | Action |
|---|---|---|
| `item.completed` with `"type":"agent_message"` | **The final answer.** The `text` field has the review or response. | Present to user. |
| `item.completed` with `"type":"reasoning"` | Codex's thinking traces. | Skip unless user asks. |
| `item.completed` with `"type":"command_execution"` | Tool calls (file reads, git commands). | Skip unless user asks. |
| `error` | Errors or reconnections (e.g. `"stream disconnected"`). | Note if the final answer is missing; Codex may have recovered and continued. |

**Parsing approach:**
1. Find all lines containing `"type":"agent_message"` — use the **last** one as the final answer (Codex may emit multiple during streaming)
2. Extract the `text` field from that JSON object
3. Present it clearly to the user
4. If no `agent_message` found, check for `error` events and report what happened
5. If the task failed and the output indicates codex was not found, run `which codex` to diagnose and inform the user

### 5. Clean up

After presenting results:

```bash
rm -f "$CODEX_OUT"
```

---

## Examples

### Code review of a branch

User: "Ask Codex to review this branch"

```bash
# Confirm there are commits to review
git log --oneline main..HEAD

# Unique output file
CODEX_OUT=$(mktemp /tmp/codex-output-XXXXXX.jsonl)

# Launch (run_in_background: true, timeout: 360000)
codex exec review --base main --json > "$CODEX_OUT" 2>&1
```

Then: inform user, wait for notification, read JSONL, extract the last `agent_message`, present findings, clean up.

### General question

User: "Ask Codex to explain the router architecture"

```bash
CODEX_OUT=$(mktemp /tmp/codex-output-XXXXXX.jsonl)
codex exec --json "Explain the router architecture in this codebase." > "$CODEX_OUT" 2>&1
```

### Implementation task

User: "Have Codex add input validation to the router"

```bash
CODEX_OUT=$(mktemp /tmp/codex-output-XXXXXX.jsonl)
codex exec --json "Add input validation to the router node." > "$CODEX_OUT" 2>&1
```
