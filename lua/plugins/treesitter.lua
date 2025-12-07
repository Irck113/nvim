-- plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {"markdown", "vim", "vimdoc", "html", "lua", "javascript", "typescript", "rust", "gdscript", "godot_resource", "gdshader" },
	auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = { 'markdown' } },
	indent = { enable = false },
      })
    end,
  },
  { 'habamax/vim-godot', event = 'VimEnter' },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufRead",
    config = function()
      --require("rainbow-delimiters").setup()
    end,
  }
}

