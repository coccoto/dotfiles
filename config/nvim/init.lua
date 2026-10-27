-- --- Leader ---
vim.g.mapleader = " "

-- --- Built-in plugins ---
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- --- Indent ---
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.smartindent = true

-- --- Search ---
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- --- Clipboard ---
vim.opt.clipboard = "unnamedplus"

-- --- Appearance ---
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.list = true

-- --- Fullwidth space ---
vim.api.nvim_set_hl(0, "FullwidthSpace", { link = "Error" })

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
    callback = function()
        if vim.w.fullwidth_space_match then
            return
        end
        vim.w.fullwidth_space_match = vim.fn.matchadd("FullwidthSpace", "\\%u3000")
    end,
})

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

-- --- Plugins: lazygit ---
vim.pack.add({
    "https://github.com/kdheepak/lazygit.nvim",
})

vim.keymap.set("n", "<leader>g", "<cmd>LazyGit<CR>")

-- --- Plugins: indent-blankline ---
vim.pack.add({
    "https://github.com/lukas-reineke/indent-blankline.nvim",
})

require("ibl").setup()
