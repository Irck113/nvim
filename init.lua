-- ============================================================================
-- LEADER KEY (debe ir ANTES que cualquier require o plugin)
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.timeoutlen = 2000
vim.keymap.set("n", "<leader>me", vim.diagnostic.open_float, { desc = "Ver error bajo cursor" })
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local project_file = vim.fn.getcwd() .. '/project.godot'
        local gdproject = io.open(project_file, 'r')

        if gdproject then
            io.close(gdproject)
            vim.fn.serverstart([[\\.\pipe\godothost]])
        end
    end
})
vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_create_autocmd({"InsertEnter"}, {
  pattern = "*",
  callback = function() vim.opt.relativenumber = false end,
})
vim.api.nvim_create_autocmd({"InsertLeave"}, {
  pattern = "*",
  callback = function() vim.opt.relativenumber = true end,
})
require("godot_onready").setup()
require("config.lazy")
