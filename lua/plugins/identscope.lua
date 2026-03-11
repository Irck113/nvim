return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",

  config = function()
    local highlight = {
      "Indent1",
      "Indent2",
      "Indent3",
      "Indent4",
      "Indent5",
      "Indent6",
    }

    local hooks = require("ibl.hooks")

    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "Indent1", { fg = "#3b4261" })
      vim.api.nvim_set_hl(0, "Indent2", { fg = "#414868" })
      vim.api.nvim_set_hl(0, "Indent3", { fg = "#4c566a" })
      vim.api.nvim_set_hl(0, "Indent4", { fg = "#545c7e" })
      vim.api.nvim_set_hl(0, "Indent5", { fg = "#5b6389" })
      vim.api.nvim_set_hl(0, "Indent6", { fg = "#646c96" })

      -- BLOQUE ACTUAL (rosa pastel)
      vim.api.nvim_set_hl(0, "IblScope", { fg = "#f5a9b8", bold = true })
    end)

    require("ibl").setup({
      indent = {
        char = "│",
        highlight = highlight,
      },

      scope = {
        enabled = true,
        highlight = "IblScope",
        show_start = false,
        show_end = false,
      },
    })
  end,
}
