os_package_manager() {
    echo "dnf"
}

os_install_packages() {
    sudo dnf install -y epel-release dnf-plugins-core
    sudo dnf copr enable -y atim/lazygit

    sudo dnf install -y "$@"
}

os_configure() {
    local dotfiles="$1"

    setx.exe WEZTERM_CONFIG_FILE "$(wslpath -w "$dotfiles/config/wezterm/wezterm.lua")" > /dev/null
}
