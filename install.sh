#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 準備
# ============================================================

# --- 前提条件 ---
if ! command -v git > /dev/null 2>&1; then
    echo "git がインストールされていません" >&2
    exit 1
fi

dotfiles="$(cd "$(dirname "$0")" && pwd)"

# --- 初期化 ---
config_dir="$HOME/.config"
share_dir="$HOME/.local/share"
bin_dir="$HOME/.local/bin"

mkdir -p "$config_dir" "$share_dir" "$bin_dir"

repos_file="$dotfiles/repos"

# ============================================================
# 設定
# ============================================================

# --- Config ---
for dir in "$dotfiles/config"/*; do
    ln -sfn "$dir" "$config_dir/$(basename "$dir")"
done

# --- OS ---
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    source "$dotfiles/install/wsl.sh"
elif [[ "$(uname -s)" == "Darwin" ]]; then
    source "$dotfiles/install/macos.sh"
fi

# ============================================================
# インストール
# ============================================================

# --- 外部ツール ---
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

while read -r url script name <&3 || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue
    install_tool "$url" "$script" "$name"
done 3< "$repos_file"

# ============================================================
# 検証
# ============================================================

# --- PATH ---
for dir in "$bin_dir" "$dotfiles/bin" "$dotfiles/local/bin"; do
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        echo "PATH に ${dir/$HOME/\$HOME} を追加してください" >&2
    fi
done
