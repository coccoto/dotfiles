#!/usr/bin/env bash
set -euo pipefail

dotfiles="$(cd "$(dirname "$0")" && pwd)"

# ============================================================
# 準備
# ============================================================
echo "準備フェーズを開始します"

# --- 前提条件 ---
if ! command -v git > /dev/null 2>&1; then
    echo "git がインストールされていません" >&2
    exit 1
fi

# --- 初期化 ---
config_dir="$HOME/.config"
share_dir="$HOME/.local/share"
bin_dir="$HOME/.local/bin"

mkdir -p "$config_dir" "$share_dir" "$bin_dir"

repos_file="$dotfiles/install/repos"

# --- 関数 ---
link() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "${target/$HOME/\$HOME} はシンボリックリンクではありません。移動または削除してから再実行してください" >&2
        exit 1
    fi

    ln -sfn "$source" "$target"
}

install_tool() {
    local url="$1"
    local script="$2"
    local name="$3"

    local repo_dir="$share_dir/$(basename "$url" .git)"

    if [[ -d "$repo_dir/.git" ]]; then
        git -C "$repo_dir" fetch --quiet
        git -C "$repo_dir" reset --quiet --hard '@{u}'
    else
        git clone --quiet "$url" "$repo_dir"
    fi

    link "$repo_dir/$script" "$bin_dir/$name"
}

# ============================================================
# 設定
# ============================================================
echo "設定フェーズを開始します"

# --- Config ---
for dir in "$dotfiles/config"/*; do
    link "$dir" "$config_dir/$(basename "$dir")"
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
echo "インストールフェーズを開始します"

# --- 外部ツール ---
while read -r url script name <&3 || [[ -n "$url" ]]; do
    [[ -z "$url" ]] && continue

    if [[ -z "$name" ]]; then
        echo "repos の書式が正しくありません: $url" >&2
        exit 1
    fi

    install_tool "$url" "$script" "$name"
done 3< "$repos_file"

# ============================================================
# 検証
# ============================================================
echo "検証フェーズを開始します"

# --- PATH ---
for dir in "$bin_dir" "$dotfiles/bin" "$dotfiles/local/bin"; do
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        echo "PATH に ${dir/$HOME/\$HOME} を追加してください" >&2
    fi
done

echo "セットアップが完了しました"
