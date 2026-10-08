#!/usr/bin/env bash
set -euo pipefail

projects_file="$HOME/.config/tmux/projects"
menu=()

while read -r project shortcut path <&3 || [[ -n "$project" ]]; do
    [[ -z "$project" ]] && continue

    if [[ -z "$path" ]]; then
        echo "projects の書式が正しくありません: $project" >&2
        exit 1
    fi

    menu+=("$project" "$shortcut" "send-keys C-u 'cd $path' Enter")
done 3< "$projects_file"

[[ ${#menu[@]} -eq 0 ]] && exit 0

tmux display-menu -T Projects "${menu[@]}"
