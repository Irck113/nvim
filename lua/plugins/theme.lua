-- lua/plugins/theme.lua
return {
  {
    --"catppuccin/nvim",
    --"rebelot/kanagawa.nvim",
    "oxfist/night-owl.nvim",
    config = function()
      vim.o.termguicolors = true
      vim.cmd.colorscheme("night-owl")
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
}

