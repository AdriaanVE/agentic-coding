---
name: preview
description: Send files or diffs to the tmux preview pane. TRIGGER when: the user says "preview" in the context of viewing files, diffs, or command output. DO NOT TRIGGER when: the user asks to "show", "display", or "read" without using the word "preview".
---

# Preview — tmux preview pane

Requires `$PREVIEW_PANE` to be set. If not set, inform the user.

## Commands

- **Preview a file**: `tmux send-keys -t $PREVIEW_PANE 'q' C-m 'preview "path/to/file"' C-m`
- **Preview git diff**: `tmux send-keys -t $PREVIEW_PANE 'q' C-m 'git diff --color | less -R' C-m`
- **Preview arbitrary output**: `tmux send-keys -t $PREVIEW_PANE 'q' C-m '<command> | less -R' C-m`

## After every file edit

Automatically show the diff in the preview pane: `tmux send-keys -t $PREVIEW_PANE 'q' C-m 'git diff --color | less -R' C-m`
