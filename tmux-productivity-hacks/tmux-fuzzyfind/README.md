# tmux-fuzzyfind

A tmux sessionizer that uses `fzf` to fuzzy-find project directories and open them in dedicated tmux sessions. Inspired by [ThePrimeagen's tmux-sessionizer](https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer).

![fzf project picker](screenshot.png)

## How it works

1. `find` scans the configured `PROJECT_DIRS` array for immediate subdirectories
2. The list is piped into `fzf` for fuzzy selection
3. A tmux session is created (or switched to) with the selected directory as its working directory, named after the folder

Pass a directory as an argument to skip the fzf picker: `tmux-sessionizer.sh ~/Code/my-project`.

## Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for project selection | `brew install fzf` |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer | `brew install tmux` |

## Installation

```bash
# Copy to a directory in your PATH
cp tmux-sessionizer.sh ~/.local/bin/
chmod +x ~/.local/bin/tmux-sessionizer.sh
```

Edit the `PROJECT_DIRS` array at the top of the script to match your workspace layout:

```bash
PROJECT_DIRS=(
    "$HOME/Code"
    "$HOME/projects"
)
```

## Keybindings

In `~/.zshrc`:

```bash
bindkey -s ^h "$HOME/.local/bin/tmux-sessionizer.sh\n"
```

In `~/.tmux.conf`:

```
bind-key -r k run-shell "$HOME/.local/bin/tmux-sessionizer.sh"
```

## macOS terminal compatibility

The script uses `TERM=xterm-256color` to avoid `tmux-256color` terminfo issues on macOS. This is handled by the shebang and the `tmux_cmd` wrapper.
