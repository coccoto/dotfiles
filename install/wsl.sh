# ============================================================
# 設定
# ============================================================

# --- WezTerm ---
setx.exe WEZTERM_CONFIG_FILE "$(wslpath -w "$dotfiles/config/wezterm/wezterm.lua")" > /dev/null
