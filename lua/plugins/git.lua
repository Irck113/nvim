-- plugins/git.lua
return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      local ok, gitsigns = pcall(require, "gitsigns")
      if not ok then return end

      gitsigns.setup({
        current_line_blame = false,
        current_line_blame_opts = { virt_text = true, delay = 1000 },
        signcolumn = true,
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- navegar hunks
          map("n", "]h", gitsigns.next_hunk, "Next hunk")
          map("n", "[h", gitsigns.prev_hunk, "Prev hunk")
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map({ "n", "v" }, "<leader>hr", ":Gitsigns.reset_hunk<CR>", "Reset Hunk")
          map("n", "<leader>hS", gitsigns.stage_buffer, "Stage Buffer")
          map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>hp", gitsigns.preview_hunk, "Preview Hunk")
          map("n", "<leader>hb", function() gitsigns.blame_line{full=true} end, "Blame Line (full)")
          map("n", "<leader>tb", function()
            -- toggle inline blame
            gitsigns.toggle_current_line_blame()
          end, "Toggle inline blame")

          -- **mapeo solicitado**: commit bajo la línea (ahora seguro, dentro de on_attach)
          map("n", "<leader>gB", function()
            gitsigns.blame_line{full=true}
          end, "Git: show commit for current line")
        end,
      })
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: repo diff" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
    },
    config = function()
      local ok, diffview = pcall(require, "diffview")
      if not ok then return end
      diffview.setup({
        use_icons = true,
        enhanced_diff_hl = true,
      })
    end,
  },

  {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = function()
      local ok, neogit = pcall(require, "neogit")
      if not ok then return end
      neogit.setup({
        integrations = { diffview = true },
      })
      vim.api.nvim_create_user_command("NeogitOpen", "Neogit", {})
    end,
    keys = {
      { "<leader>gS", "<cmd>Neogit<cr>", desc = "Neogit (status/branches/commits)" },
    },
  },

  {
    "pwntester/octo.nvim",
    cmd = { "Octo", "OctoPr" },
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      local ok, octo = pcall(require, "octo")
      if not ok then return end
      octo.setup({
        default_remote = { "upstream", "origin" },
      })
    end,
    keys = {
      { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "GitHub: List PRs (octo)" },
    },
  },

  {
    "ruifm/gitlinker.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ok, gl = pcall(require, "gitlinker")
      if not ok then return end
      gl.setup()
      vim.keymap.set("n", "<leader>gl", function()
        require("gitlinker").get_buf_range_url("n", {action_callback = function(url)
          vim.fn.setreg("+", url)
          print("URL copiada al portapapeles: " .. url)
        end})
      end, { desc = "Git: copiar link del archivo/commit" })
    end,
  },

  {
    "nvim-lua/plenary.nvim",
    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_user_command("GitAddCurrent", function()
        local file = vim.fn.expand("%")
        if file == "" then print("No file") return end
        vim.cmd("Git add " .. vim.fn.shellescape(file))
        print("Staged " .. file)
      end, {})

      vim.api.nvim_create_user_command("GitAddAll", function()
        vim.cmd("Git add -A")
        print("Staged all changes")
      end, {})

      vim.api.nvim_create_user_command("GitCommit", function(opts)
        local msg = opts.args
        if msg == "" then
          vim.cmd("Git commit")
          return
        end
        vim.cmd("Git commit -m " .. vim.fn.shellescape(msg))
      end, { nargs = "*" })

      vim.keymap.set("n", "<leader>ga", "<cmd>GitAddCurrent<cr>", { desc = "Git: add current file" })
      vim.keymap.set("n", "<leader>gA", "<cmd>GitAddAll<cr>", { desc = "Git: add all" })
      vim.keymap.set("n", "<leader>gc", "<cmd>GitCommit ", { desc = "Git: commit (use :GitCommit <msg> or open :Git commit)" })
    end,
  },
}
