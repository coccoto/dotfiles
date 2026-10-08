local wezterm = require 'wezterm'
local config = wezterm.config_builder()

if wezterm.target_triple:find('windows') then
    -- 設定ファイルのパスから <distribution> を抽出する
    -- \\wsl.localhost\<distribution>\...\wezterm.lua → <distribution>
    local distribution = wezterm.config_file:match([[^\\wsl[^\]+\([^\]+)]])
    if distribution then
        config.default_domain = 'WSL:' .. distribution
    end
end

return config
