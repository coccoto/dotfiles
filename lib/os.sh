is_wsl() {
    [[ "$(uname -r)" == *microsoft* ]]
}

is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}
