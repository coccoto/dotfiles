local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- --- General ---
config.window_close_confirmation = 'NeverPrompt'

-- --- Key bindings ---
config.keys = {{ key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\n') }}

-- --- OS 依存の設定 ---
if wezterm.target_triple:find('windows') then
    -- 設定ファイルのパスからディストリビューションを抽出する
    local distribution = wezterm.config_file:match([[^\\wsl[^\]+\([^\]+)]])
    if distribution then
        config.default_domain = 'WSL:' .. distribution
    end
end

return config
