return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require('treesitter-context').setup({
      enable = true,
      max_lines = 0,
      min_window_height = 0,
      trim_scope = 'outer',
      patterns = {
        default = {
          'class', 'function', 'method', 'for', 'while', 'if', 'switch', 'case',
        },
        -- You can set filetype-specific patterns like this:
        -- lua = {'function', 'table_constructor'},
      },

      -- How far (in lines) a node can be to still be shown as context when it
      -- spans multiple lines. If node is longer than this it will not be shown
      multiline_threshold = 9999999,

      -- When set to true the plugin will throttle updates (better performance)
      throttle = true,

      -- When context is displayed, optionally show a separator line below it.
      -- Can be a string (single character) to draw a line, or nil to disable.
      separator = '─',

      -- Z-index for context window (higher draws on top of other floating windows)
      zindex = 20,

      -- Update strategy: 'cursor' (on cursor movement) or 'lsp' (on LSP callbacks)
      mode = 'lsp',
    })

    -- Optional: convenience toggle keymap
    vim.keymap.set('n', '<leader>ct', function()
      require('treesitter-context').toggle()
    end, { desc = 'Toggle sticky context' })
  end,
}
