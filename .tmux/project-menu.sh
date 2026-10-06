#!/usr/bin/env bash
set -euo pipefail

projects="$HOME/.tmux/projects"
menu=()

while read -r project shortcut path || [[ -n "$project" ]]; do
    [[ -z "$path" ]] && continue
    # 表示名 ショートカット 実行コマンド
    menu+=("$project" "$shortcut" "send-keys C-u 'cd $path' Enter")
done < "$projects"

[[ ${#menu[@]} -eq 0 ]] && exit 0

tmux display-menu -T Projects "${menu[@]}"
