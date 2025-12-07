return {
  {
    "ellisonleao/glow.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("glow").setup({
        style = "dark",
        width = 120,
	border = 'rounded'
      })
	vim.keymap.set("n", "<leader>mg", ":Glow<CR>", { desc = "Glow: preview markdown" })
    end,
  },
}
