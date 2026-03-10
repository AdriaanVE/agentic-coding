---
name: preview
description: Send files or diffs to the tmux preview pane. Use when the user asks to preview a file, diff, or any output in the side pane.
---

# Preview — tmux preview pane

Requires `$PREVIEW_PANE` to be set. If not set, inform the user.

## Commands

- **Preview a file**: `tmux send-keys -t $PREVIEW_PANE 'q' C-m 'preview "path/to/file"' C-m`
- **Preview git diff**: `tmux send-keys -t $PREVIEW_PANE 'q' C-m 'git diff --color | less -R' C-m`
- **Preview arbitrary output**: `tmux send-keys -t $PREVIEW_PANE 'q' C-m '<command> | less -R' C-m`

## After every file edit

Automatically show the diff in the preview pane: `tmux send-keys -t $PREVIEW_PANE 'q' C-m 'git diff --color | less -R' C-m`
