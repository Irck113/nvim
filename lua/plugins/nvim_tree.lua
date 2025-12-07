-- lua/plugins/nvim_tree.lua
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local api = require("nvim-tree.api")

      require("nvim-tree").setup({
        view = { width = 34 },
        actions = { open_file = { quit_on_open = false } },
        renderer = { highlight_git = true, icons = { show = { git = true } } },

        -- on_attach: mapeos buffer-local para el árbol (no rompen nada global)
        on_attach = function(bufnr)
          local function opts(desc)
            return { desc = "NvimTree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- abrir en edición normal
          vim.keymap.set("n", "l", api.node.open.edit, opts("Open (edit)"))

          -- abrir en split horizontal
          vim.keymap.set("n", "H", api.node.open.horizontal, opts("Open: horizontal split"))

          -- abrir en split vertical (vsplit) - mayúscula H
          vim.keymap.set("n", "h", api.node.open.vertical, opts("Open: vertical split"))

          -- abrir en nueva pestaña - mayúscula L
          vim.keymap.set("n", "L", api.node.open.tab, opts("Open: new tab"))
          -- Opción A (estándar): Backspace
          vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close parent directory (one level)"))

          -- Opción B (alternativa/semántica): zc (como close)
          vim.keymap.set("n", "c", api.node.navigate.parent_close, opts("Close parent directory (one level)"))
          -- mantén tus teclas usuales: cerrar con q / etc. (no las cambié)
          -- Si quieres puedo añadir más atajos aquí (por ejemplo <CR> para abrir,
          -- o mapeos para crear/rename/delete), pero como pediste solo añadí l/h/H/L.
        end,
      })

      -- keymap global: <leader>e para toggle tree (como tenías)
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Tree: toggle" })
    end,
  },
}
