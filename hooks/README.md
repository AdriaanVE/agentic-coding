# PermissionRequest Hook — AI-Powered Safety Evaluator

Automatically evaluates Claude Code tool calls for safety using Sonnet via Azure Foundry. Safe operations are auto-approved; dangerous ones trigger a warning and the normal permission dialog.

## How It Works

1. Claude Code fires a `PermissionRequest` event before executing a tool call
2. The hook sends the tool name and input to Sonnet for security review
3. Sonnet evaluates against criteria (destructive ops, sensitive files, network requests, data loss, untrusted code)
4. Safe calls are auto-approved; risky calls show a warning to the user

The hook **fails open** — if credentials are missing or the API call fails, the normal permission dialog is shown.

## Installation

### 1. Copy the script

Copy `permission-evaluator.sh` to your Claude hooks directory:

```bash
cp hooks/permission-evaluator.sh ~/.claude/hooks/permission-evaluator.sh
chmod +x ~/.claude/hooks/permission-evaluator.sh
```

### 2. Add the hook config to your settings

Merge the contents of `settings-snippet.json` into your Claude settings file.

| Scope | File |
|-------|------|
| Global (all projects) | `~/.claude/settings.json` |
| Project (shared/committed) | `<project>/.claude/settings.json` |
| Project (local/gitignored) | `<project>/.claude/settings.local.json` |

Example — add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Bash|Read|Task|WebSearch|WebFetch|Grep|Glob",
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/permission-evaluator.sh",
            "timeout": 20,
            "statusMessage": "Evaluating permission request..."
          }
        ]
      }
    ]
  }
}
```

By default, `Bash`, `Read`, `Task`, `WebSearch`, `WebFetch`, `Grep`, and `Glob` tool calls are evaluated. Matchers support regex, so they're combined in a single entry.

`Edit` and `Write` are deliberately excluded. These are the most impactful tools — they modify your codebase — so you want to review proposed changes before they're applied rather than having them auto-approved by the AI evaluator.

### 3. Configure credentials

The script sources `~/dotenvs/claude.env` which must export:

- `ANTHROPIC_FOUNDRY_RESOURCE` — your Azure AI Foundry resource name
- `ANTHROPIC_FOUNDRY_API_KEY` — your API key
- `ANTHROPIC_DEFAULT_SONNET_MODEL` — (optional) defaults to `claude-sonnet-4-5`

## Matchers

You can scope a hook to specific tools using the `matcher` field. Without a matcher, the hook runs on **every** permission request.

### Match a single tool

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/permission-evaluator.sh",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```

### Match multiple tools

Use regex to combine matchers in a single entry:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "Bash|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$HOME\"/.claude/hooks/permission-evaluator.sh",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```

### Available tool names for matchers

Common tools you can match on:

| Matcher | Triggers on |
|---------|------------|
| `Bash` | Shell command execution |
| `Read` | File reads |
| `Edit` | File edits |
| `Write` | File creation/overwrite |
| `Glob` | File pattern matching |
| `Grep` | Content search |
| `Task` | Subagent spawning |
| `WebFetch` | HTTP requests |
| `WebSearch` | Web searches |
| `NotebookEdit` | Jupyter notebook modifications |

Omit `matcher` entirely to catch all tools.

## Hook Input

The script receives a JSON object on stdin with these fields:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/foo",
    "description": "Delete temp directory"
  }
}
```

## Customization

### Adjust the evaluation prompt

Edit the `PROMPT` variable in `permission-evaluator.sh` to change what Sonnet considers safe or dangerous. The default criteria are:

1. Destructive operations (rm -rf, force push, drop table, git reset --hard)
2. Sensitive file access (.env, credentials, private keys, secrets)
3. Network requests to untrusted/external destinations
4. Data loss or irreversible damage
5. Package installation or untrusted code execution

### Adjust the timeout

The `timeout` field in the settings snippet (seconds) controls how long Claude Code waits for the hook. The `--max-time 15` in the curl call is the API request timeout. Adjust both if needed.
