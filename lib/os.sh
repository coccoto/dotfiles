is_wsl() {
    [[ "$(uname -r)" == *microsoft* ]]
}

is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

detect_os() {
    if is_wsl; then
        echo "wsl"
    elif is_macos; then
        echo "macos"
    fi
}
