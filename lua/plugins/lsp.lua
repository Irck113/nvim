-- ===== nvim-lspconfig (API recomendada) =====
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    -- helpers comunes
    local function on_attach_common(client, bufnr)
      local bufmap = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      bufmap("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
      bufmap("n", "gr", vim.lsp.buf.references, "LSP: references")
      bufmap("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
      bufmap("n", "K", vim.lsp.buf.hover, "LSP: hover docs")
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
      bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Función helper que registra usando la API recomendada
    local function register_lsp(name, opts)
      opts = opts or {}
      opts.on_attach = opts.on_attach or on_attach_common
      opts.capabilities = opts.capabilities or capabilities

      -- Registrar la config y luego habilitarla
      pcall(function()
        vim.lsp.config(name, opts)
        vim.lsp.enable(name)
      end)
    end

    -- ===== TypeScript / JS =====
    register_lsp("ts_ls", {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      root_markers = { 'package.json' },
      settings = {},
    })

    -- ===== Rust =====
    register_lsp("rust_analyzer", {
      filetypes = {"rs"},
      root_markers = { 'Cargo.toml' },
      settings = {},
    })

    -- ===== GDScript (Godot) =====
    local gd_cfg = {
      filetypes = { "gd", "gdscript" },
      root_markers = {'project.godot'},
      settings = {},
    }

    -- ===== PHP =====
    register_lsp("intelephense", {
      filetypes = { "php" },
      root_markers = {'artisan'},
    })
    if vim.fn.has("win32") == 1 then
      local port = tonumber(os.getenv("GDScript_Port")) or 6005
      gd_cfg.cmd = { "ncat", "localhost", tostring(port) }
      -- gd_cfg.cmd = { "gdscript-language-server", "--stdio" }
    end

    register_lsp("gdscript", gd_cfg)
  end,
}
