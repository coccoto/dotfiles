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

check_package_manager() {
    local package_manager="$(os_package_manager)"

    if ! command -v "$package_manager" > /dev/null 2>&1; then
        echo "$package_manager が見つかりません" >&2
        exit 1
    fi
}

confirm_continue() {
    local message="$1"

    echo "$message"

    local answer
    read -r -p "続けますか？ [y/N] " answer
    if [[ "$answer" != [yY] ]]; then
        echo "セットアップを中止しました" >&2
        exit 1
    fi
}

install_packages() {
    local packages_file="$1"
    local os="$2"

    local packages=()

    local package target_os
    while read -r package target_os <&3 || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == "#"* ]] && continue

        if [[ -z "$target_os" ]]; then
            echo "packages の形式が正しくありません: $package" >&2
            exit 1
        fi

        if [[ "$target_os" == "all" || "$target_os" == "$os" ]]; then
            packages+=("$package")
        fi
    done 3< "$packages_file"

    [[ ${#packages[@]} -eq 0 ]] && return

    confirm_continue "次のパッケージをインストールします: ${packages[*]}"

    os_install_packages "${packages[@]}"
}

create_symlink() {
    local source_path="$1"
    local link_path="$2"

    if [[ -e "$link_path" && ! -L "$link_path" ]]; then
        echo "${link_path/$HOME/\$HOME} はシンボリックリンクではありません。移動または削除してから再実行してください" >&2
        exit 1
    fi

    ln -sfn "$source_path" "$link_path"
}

link_configs() {
    local dotfiles="$1"
    local config_dir="$2"

    local source_dir
    for source_dir in "$dotfiles/config"/*; do
        create_symlink "$source_dir" "$config_dir/$(basename "$source_dir")"
    done
}

fetch_git() {
    local url="$1"
    local tool_dir="$2"

    if [[ -d "$tool_dir/.git" ]]; then
        git -C "$tool_dir" fetch --quiet
        git -C "$tool_dir" reset --quiet --hard '@{u}'
    else
        git clone --quiet "$url" "$tool_dir"
    fi
}

fetch_zip() {
    local url="$1"
    local tool_dir="$2"

    local tmp_dir="$(mktemp -d)"

    curl -fsSL -o "$tmp_dir/download.zip" "$url"
    rm -rf "$tool_dir"
    unzip -q "$tmp_dir/download.zip" -d "$tool_dir"

    rm -rf "$tmp_dir"
}

install_tools() {
    local tools_file="$1"
    local os="$2"
    local data_dir="$3"
    local bin_dir="$4"

    local tools=()
    local command_names=()

    local url command_path command_name target_os
    while read -r url command_path command_name target_os <&3 || [[ -n "$url" ]]; do
        [[ -z "$url" || "$url" == "#"* ]] && continue

        if [[ -z "$target_os" ]]; then
            echo "tools の形式が正しくありません: $url" >&2
            exit 1
        fi

        if [[ "$target_os" == "all" || "$target_os" == "$os" ]]; then
            tools+=("$url $command_path $command_name")
            command_names+=("$command_name")
        fi
    done 3< "$tools_file"

    [[ ${#tools[@]} -eq 0 ]] && return

    confirm_continue "次のツールをインストールします: ${command_names[*]}"

    local tool tool_dir
    for tool in "${tools[@]}"; do
        read -r url command_path command_name <<< "$tool"

        tool_dir="$data_dir/$command_name"

        case "$url" in
            *.git)
                fetch_git "$url" "$tool_dir"
                ;;
            *.zip)
                fetch_zip "$url" "$tool_dir"
                ;;
            *)
                echo "対応していない形式です: $url" >&2
                exit 1
                ;;
        esac

        create_symlink "$tool_dir/$command_path" "$bin_dir/$command_name"
    done
}

check_path() {
    local dotfiles="$1"
    local bin_dir="$2"

    local path_dir
    for path_dir in "$bin_dir" "$dotfiles/bin" "$dotfiles/local/bin"; do
        if [[ ":$PATH:" != *":$path_dir:"* ]]; then
            echo "PATH に ${path_dir/$HOME/\$HOME} を追加してください" >&2
        fi
    done
}

main() {
    local dotfiles="$1"

    echo "セットアップを開始します"

    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    local share_dir="${XDG_DATA_HOME:-$HOME/.local/share}"

    local data_dir="$share_dir/dotfiles"
    local bin_dir="$HOME/.local/bin"

    local os="$(detect_os)"

    load_os "$dotfiles" "$os"
    check_package_manager
    install_packages "$dotfiles/install/packages" "$os"

    mkdir -p "$config_dir" "$data_dir" "$bin_dir"

    link_configs "$dotfiles" "$config_dir"
    os_configure "$dotfiles"
    install_tools "$dotfiles/install/tools" "$os" "$data_dir" "$bin_dir"

    check_path "$dotfiles" "$bin_dir"

    echo "セットアップが完了しました"
}

main "$dotfiles"
