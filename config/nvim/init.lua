-- --- Leader ---
vim.g.mapleader = " "

-- --- Built-in plugins ---
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- --- Line numbers ---
vim.opt.number = true
vim.opt.relativenumber = true

-- --- Indent ---
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.smartindent = true

-- --- Search ---
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- --- Appearance ---
vim.opt.cursorline = true

-- --- IME ---
vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        vim.system({ "ime-off" })
    end,
})

-- --- Plugins: nvim-tree ---
vim.pack.add({
    "https://github.com/nvim-tree/nvim-tree.lua",
})

require("nvim-tree").setup()

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
