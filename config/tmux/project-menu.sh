#!/usr/bin/env bash
set -euo pipefail

projects_file="$HOME/.config/tmux/projects"
menu_items=()

while read -r project_name shortcut project_dir <&3 || [[ -n "$project_name" ]]; do
    [[ -z "$project_name" || "$project_name" == "#"* ]] && continue

    if [[ -z "$project_dir" ]]; then
        echo "projects の形式が正しくありません: $project_name" >&2
        exit 1
    fi

    menu_items+=("$project_name" "$shortcut" "send-keys C-u 'cd $project_dir' Enter")
done 3< "$projects_file"

[[ ${#menu_items[@]} -eq 0 ]] && exit 0

tmux display-menu -T Projects "${menu_items[@]}"
