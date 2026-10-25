local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- --- General ---
config.window_close_confirmation = 'NeverPrompt'

-- --- Key bindings ---
config.keys = {{ key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\n') }}

-- --- OS specific ---
if wezterm.target_triple:find('windows') then
    table.insert(config.keys, { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom('Clipboard') })

    -- 設定ファイルのパスからディストリビューションを抽出する
    local wsl_distro = wezterm.config_file:match([[^\\wsl[^\]+\([^\]+)]])
    if wsl_distro then
        config.default_domain = 'WSL:' .. wsl_distro
    end
end

return config
