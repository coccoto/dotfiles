os_package_manager() {
    echo "brew"
}

os_install_packages() {
    brew install -q -y "$@"
}

os_configure() {
    local dotfiles="$1"
}
