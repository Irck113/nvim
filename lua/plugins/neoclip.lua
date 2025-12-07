-- clipboard history (neoclip) -- versión robusta para evitar errores E5108
return {
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      -- si quieres persistencia instala kkharji/sqlite.lua; lo dejamos como opcional
      { "kkharji/sqlite.lua", optional = true },
    },
    config = function()
      -- intentar requerir neoclip de forma segura
      local ok, neoclip_or_err = pcall(require, "neoclip")
      if not ok then
        vim.notify("neoclip: no se pudo requerir: " .. tostring(neoclip_or_err), vim.log.levels.WARN)
        -- No hacemos setup para evitar que el TextYankPost autocommand rompa.
        return
      end

      -- comprobar si sqlite está disponible (para activar persistencia)
      local sqlite_ok = pcall(require, "sqlite")
      if not sqlite_ok then
        -- opcional: notificar pero seguir sin persistencia
        vim.notify("neoclip: sqlite.lua no disponible, persistencia desactivada", vim.log.levels.INFO)
      end

      -- setup con un fallback seguro: si no hay sqlite, enable_persistent_history = false
      neoclip_or_err.setup({
        history = 1000,
        enable_persistent_history = sqlite_ok and true or false,
        -- ruta por defecto para la DB (no la toques a menos que sepas)
        db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      })

      -- registrar extensión de telescope si telescope y la extensión existen
      pcall(function()
        local tel_ok, _ = pcall(require, "telescope")
        if tel_ok then
          pcall(require("telescope").load_extension, "neoclip")
        end
      end)
    end,

    keys = {
      { "<leader>cp", "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", desc = "Clipboard history" },
    },
  },
}
