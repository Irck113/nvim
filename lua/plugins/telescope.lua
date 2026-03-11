-- plugins/telescope.lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {"nvim-telescope/telescope-fzf-native.nvim" , build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"},
      "AckslD/nvim-neoclip.lua",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Buscar archivos" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar archivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar en texto" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Ver buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Buscar ayuda" },
      { "<leader>?", "<cmd>Telescope builtin<cr>", desc = "Todos los pickers" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },

      -- LSP quick pickers
      { "<leader>lr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", desc = "LSP: references" },
      { "<leader>ld", "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", desc = "LSP: definitions" },
      { "<leader>li", "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", desc = "LSP: implementations" },
      { "<leader>le", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>lS", "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>", desc = "Workspace symbols" },
      {
	      "<leader>ls",
	      function()
		      require("telescope.builtin").treesitter({
			      symbols = { "function", "method" },
		      })
	      end,
	      desc = "Treesitter functions",
      },
      -- grep_string (palabra bajo cursor)
      { "<leader>gw", "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.expand('<cword>') })<cr>", desc = "Grep palabra bajo cursor" },

      -- Git pickers via Telescope
      { "<leader>gf", "<cmd>lua require('telescope.builtin').git_files()<cr>", desc = "Git: archivos tracked" },
      { "<leader>gS", "<cmd>lua require('telescope.builtin').git_status()<cr>", desc = "Git: estado (telescope)" },

      -- Neoclip
      { "<leader>fy", "<cmd>Telescope neoclip<cr>", desc = "Clipboard history" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local entry_display = require("telescope.pickers.entry_display")

      -- Helper: busca hacia arriba en el árbol por archivos que identifiquen el root (project.godot)
      local function find_project_root(startpath)
        local uv = vim.loop
        local path_sep = package.config:sub(1,1)
        local dir = startpath or vim.fn.getcwd()
        dir = uv.fs_realpath(dir) or dir

        while dir do
          -- comprueba project.godot
          local godot_path = dir .. path_sep .. "project.godot"
          if uv.fs_stat(godot_path) then
            return dir
          end

          -- si llegamos a la raíz, salimos
          local parent = dir:match("(.*)" .. path_sep)
          if not parent or parent == dir then
            break
          end
          dir = parent
        end
        return nil
      end

      -- Construye find_command optimizado para proyectos Godot (solo extensiones permitidas)
      local function build_godot_find_command()
        -- extensiones aceptadas en Godot
        local exts = { "gd", "gdshader", "gdshaders", "md" } -- incluyo gdshaders por si acaso
        -- exclusions comunes
        local excludes = {
          ".git/",
	  "vendor",
	  "build",
	  "dist",
          "node_modules",
        }
        -- exclude image/binary patterns
        local image_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.ico" }
        local binary_patterns = { "*.exe", "*.dll", "*.so", "*.dylib" }

        -- preferir fd si existe
        if vim.fn.executable("fd") == 1 then
          local cmd = { "fd", "--type", "f", "--hidden", "--no-ignore-vcs" }
          -- añadir extensiones con -e
          for _, e in ipairs(exts) do table.insert(cmd, "-e"); table.insert(cmd, e) end
          -- excluir carpetas
          for _, ex in ipairs(excludes) do table.insert(cmd, "--exclude"); table.insert(cmd, ex) end
          -- excluir images / binaries
          for _, p in ipairs(image_patterns) do table.insert(cmd, "--exclude"); table.insert(cmd, p) end
          for _, p in ipairs(binary_patterns) do table.insert(cmd, "--exclude"); table.insert(cmd, p) end
          return cmd
        end

        -- fallback a ripgrep (rg)
        if vim.fn.executable("rg") == 1 then
          local cmd = { "rg", "--files", "--hidden", "--no-ignore-vcs" }
          -- incluir solo las globs de extensiones (rg acepta múltiples -g)
          for _, e in ipairs(exts) do table.insert(cmd, "-g"); table.insert(cmd, "*." .. e) end
          -- excluir carpetas y patrones
          for _, ex in ipairs(excludes) do table.insert(cmd, "-g"); table.insert(cmd, "!" .. ex .. "/**") end
          for _, p in ipairs(image_patterns) do table.insert(cmd, "-g"); table.insert(cmd, "!" .. p) end
          for _, p in ipairs(binary_patterns) do table.insert(cmd, "-g"); table.insert(cmd, "!" .. p) end
          return cmd
        end

        -- último recurso: use find (más lento, pero ampliamente disponible)
        -- construimos un find que filtre por extensiones y excluya .git e imágenes
        local find_parts = { "sh", "-c" }
        local patterns = {}
        for _, e in ipairs(exts) do table.insert(patterns, "-iname '*." .. e .. "'") end
        local find_cmd = "find . \\( " .. table.concat(patterns, " -o ") .. " \\) -type f"
        -- exclude .git
        find_cmd = find_cmd .. " -not -path './.git/*'"
        for _, p in ipairs(image_patterns) do find_cmd = find_cmd .. " -not -iname '" .. p .. "'" end
        for _, p in ipairs(binary_patterns) do find_cmd = find_cmd .. " -not -iname '" .. p .. "'" end
        table.insert(find_parts, find_cmd)
        return find_parts
      end

      telescope.setup({
        defaults = {
          -- Por defecto abrimos en modo Normal
          initial_mode = "normal",
	  file_ignore_patterns = {
		  "%.git/",
		  "vendor/",
		  "build/",
		  "dist/",
		  "node_modules/",
	  },
          mappings = {
            -- Mapeos en modo Normal dentro del popup de Telescope
            n = {
              -- `l` abre el entry seleccionado en el buffer normal
              ["l"] = actions.select_default,
              ["L"] = actions.select_tab,
              -- `h` abre el entry seleccionado en split horizontal
              ["H"] = actions.select_horizontal,
              ["h"] = actions.select_vertical,
              -- cerrar rápido / navegación conservada
              ["q"] = actions.close,
              -- puedes seguir usando <CR> 
            },
            -- Mapeos en modo Insert 
            i = {
              -- <esc> cierra 
              ["<esc>"] = actions.close,
            },
          },
        },

        -- Pickers específicos: override de comportamiento por tipo
        pickers = {
          -- Mantengo tema dropdown para find_files
          find_files = {
            theme = "dropdown",
            -- find_files: nos interesa entrar en normal (por defecto)
            initial_mode = "normal",

            -- override: si estamos en un proyecto Godot, usamos un comando que limite a .gd/.gdshader/.md
            find_command = (function()
              local root = find_project_root()
              if root then
                -- estamos dentro de un Godot project -> devolver comando optimizado
                return build_godot_find_command()
              end
              -- si no hay project.godot, devolvemos nil -> telescope usará su comportamiento por defecto
              return nil
            end)(),
          },

          -- live_grep: más práctico entrar en modo insert directamente
          live_grep = {
            initial_mode = "insert",
          },

          -- buffers: útil entrar en insert para filtrar rápido
          buffers = {
            initial_mode = "insert",
          },

          -- help_tags: igual, es cómodo escribir desde el inicio
          help_tags = {
            initial_mode = "insert",
          },
        },
      })

      pcall(telescope.load_extension, "fzf")     
      pcall(telescope.load_extension, "neoclip")       
      pcall(telescope.load_extension, "file_browser")  
    end,
  },
}
