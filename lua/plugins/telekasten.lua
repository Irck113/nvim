return {
  {
    "renerocksai/telekasten.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local home = vim.fn.expand("G:\\Mi unidad\\Jardin") -- <-- EDITA TU RUTA AQUÍ

      require("telekasten").setup({
        home = home,

        -- Opcional: carpeta para imágenes
        image_subdir = "900_Assets",
        image_link_style = "markdown",
        auto_set_filetype = false,
      })

      local zk = require("telekasten")

      -- Keymaps
      vim.keymap.set("n", "<leader>zf", zk.follow_link, { desc = "Seguir link Telekasten" })
      vim.keymap.set("n", "<leader>zn", zk.new_note,     { desc = "Nueva nota" })
      vim.keymap.set("n", "<leader>zi", zk.paste_img_and_link, { desc = "Pegar imagen y link" })
      vim.keymap.set("n", "<leader>zs", zk.search_notes, { desc = "Buscar notas" })
    end,
  },
}
