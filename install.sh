#!/usr/bin/env bash
set -euo pipefail

dotfiles="$(cd "$(dirname "$0")" && pwd)"

source "$dotfiles/lib/os.sh"

load_os() {
    local dotfiles="$1"
    local os="$2"

    if [[ -z "$os" ]]; then
        echo "対応していない OS です" >&2
        exit 1
    fi

    source "$dotfiles/install/$os.sh"
}

preflight() {
    local manager="$(os_package_manager)"
    if ! command -v "$manager" > /dev/null 2>&1; then
        echo "$manager が見つかりません" >&2
        exit 1
    fi
}

install_packages() {
    local deps_file="$1"
    local os="$2"

    local packages=()
    local name target
    while read -r name target <&3 || [[ -n "$name" ]]; do
        [[ -z "$name" ]] && continue

        if [[ -z "$target" ]]; then
            echo "deps の形式が正しくありません: $name" >&2
            exit 1
        fi

        if [[ "$target" == "all" || "$target" == "$os" ]]; then
            packages+=("$name")
        fi
    done 3< "$deps_file"

    [[ ${#packages[@]} -eq 0 ]] && return

    echo "次のパッケージをインストールします: ${packages[*]}"

    local answer
    read -r -p "続けますか？ [y/N] " answer
    if [[ "$answer" != [yY] ]]; then
        echo "セットアップを中止しました" >&2
        exit 1
    fi

    os_install_packages "${packages[@]}"
}

create_symlink() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "${target/$HOME/\$HOME} はシンボリックリンクではありません。移動または削除してから再実行してください" >&2
        exit 1
    fi

    ln -sfn "$source" "$target"
}

link_configs() {
    local dotfiles="$1"
    local config_dir="$2"

    local dir
    for dir in "$dotfiles/config"/*; do
        create_symlink "$dir" "$config_dir/$(basename "$dir")"
    done
}

install_tool() {
    local url="$1"
    local script="$2"
    local name="$3"
    local share_dir="$4"
    local bin_dir="$5"

    local repo_dir="$share_dir/$(basename "$url" .git)"

    if [[ -d "$repo_dir/.git" ]]; then
        git -C "$repo_dir" fetch --quiet
        git -C "$repo_dir" reset --quiet --hard '@{u}'
    else
        git clone --quiet "$url" "$repo_dir"
    fi

    create_symlink "$repo_dir/$script" "$bin_dir/$name"
}

install_tools() {
    local repos_file="$1"
    local share_dir="$2"
    local bin_dir="$3"

    local url script name
    while read -r url script name <&3 || [[ -n "$url" ]]; do
        [[ -z "$url" ]] && continue

        if [[ -z "$name" ]]; then
            echo "repos の形式が正しくありません: $url" >&2
            exit 1
        fi

        install_tool "$url" "$script" "$name" "$share_dir" "$bin_dir"
    done 3< "$repos_file"
}

check_path() {
    local dotfiles="$1"
    local bin_dir="$2"

    local dir
    for dir in "$bin_dir" "$dotfiles/bin" "$dotfiles/local/bin"; do
        if [[ ":$PATH:" != *":$dir:"* ]]; then
            echo "PATH に ${dir/$HOME/\$HOME} を追加してください" >&2
        fi
    done
}

main() {
    local dotfiles="$1"

    echo "セットアップを開始します"

    local config_dir="$HOME/.config"
    local share_dir="$HOME/.local/share"
    local bin_dir="$HOME/.local/bin"
    local os="$(current_os)"

    load_os "$dotfiles" "$os"
    preflight
    install_packages "$dotfiles/install/deps" "$os"

    mkdir -p "$config_dir" "$share_dir" "$bin_dir"

    link_configs "$dotfiles" "$config_dir"
    os_configure "$dotfiles"
    install_tools "$dotfiles/install/repos" "$share_dir" "$bin_dir"
    check_path "$dotfiles" "$bin_dir"

    echo "セットアップが完了しました"
}

main "$dotfiles"
