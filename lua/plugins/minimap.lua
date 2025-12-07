-- lua/plugins/minimap.lua
return {
  "echasnovski/mini.map",
  version = false,
  config = function()
    local map = require("mini.map")

    map.setup({
      integrations = {
        map.gen_integration.builtin_search(),
        map.gen_integration.gitsigns(),
      },
      symbols = {
        encode = map.gen_encode_symbols.dot("4x2"),
      },
      window = {
        show_integration_count = false,
        width = 20,
      },
    })

    -- Abrir el minimapa ahora (al iniciar)
    pcall(function() map.open() end)

    -- Asegurar que se abra al leer o crear archivos nuevos
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      callback = function()
        -- uso pcall para evitar errores raros en buffers especiales
        pcall(function() require("mini.map").open() end)
      end,
    })

    -- Atajo opcional para alternar (lo puedes mantener)
    vim.keymap.set("n", "<leader>mm", map.toggle, { desc = "MiniMap: toggle" })
  end,
}
