macos_trust_tap_formulae() {
    local package
    for package in "$@"; do
        if [[ "$package" == */*/* ]]; then
            brew trust --formula "$package"
        fi
    done
}

os_package_manager() {
    echo "brew"
}

os_install_packages() {
    macos_trust_tap_formulae "$@"

    brew install -q -y "$@"
}

os_configure() {
    local dotfiles="$1"
}
