#!/usr/bin/env bash
set -euo pipefail

projects_file="$HOME/.tmux/projects"
menu=()

while read -r project shortcut path <&3 || [[ -n "$project" ]]; do
    [[ -z "$path" ]] && continue
    # 表示名 ショートカット 実行コマンド
    menu+=("$project" "$shortcut" "send-keys C-u 'cd $path' Enter")
done 3< "$projects_file"

[[ ${#menu[@]} -eq 0 ]] && exit 0

tmux display-menu -T Projects "${menu[@]}"
