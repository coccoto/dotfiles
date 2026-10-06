#!/usr/bin/env bash
set -euo pipefail

dotfiles="$(cd "$(dirname "$0")" && pwd)"

# tmux
ln -sfn "$dotfiles/.tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$dotfiles/.tmux" "$HOME/.tmux"
