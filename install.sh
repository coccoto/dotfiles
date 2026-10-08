#!/usr/bin/env bash
set -euo pipefail

if ! command -v git > /dev/null 2>&1; then
    echo "git がインストールされていません" >&2
    exit 1
fi

dotfiles="$(cd "$(dirname "$0")" && pwd)"

# ------------------------------------------------------------
# tmux
# ------------------------------------------------------------
ln -sfn "$dotfiles/.tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$dotfiles/.tmux" "$HOME/.tmux"

# ------------------------------------------------------------
# 外部ツール
# ------------------------------------------------------------
share_dir="$HOME/.local/share"
bin_dir="$HOME/.local/bin"

repos_file="$dotfiles/repos"

install_tool() {
    local url="$1"
    local script="$2"
    local name="$3"

    local repo_dir="$share_dir/$(basename "$url" .git)"

    if [[ -d "$repo_dir/.git" ]]; then
        git -C "$repo_dir" fetch
        git -C "$repo_dir" reset --hard '@{u}'
    else
        git clone "$url" "$repo_dir"
    fi

    ln -sfn "$repo_dir/$script" "$bin_dir/$name"
}

mkdir -p "$bin_dir"

while read -r url script name <&3 || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    # URL 実行スクリプト コマンド名
    install_tool "$url" "$script" "$name"
done 3< "$repos_file"

# ------------------------------------------------------------
# PATH の確認
# ------------------------------------------------------------
for dir in "$bin_dir" "$dotfiles/bin" "$dotfiles/local/bin"; do
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        echo "PATH に ${dir/$HOME/\$HOME} を追加してください" >&2
    fi
done
