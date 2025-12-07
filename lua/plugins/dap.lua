-- plugins/dap.lua
return {
  "mfussenegger/nvim-dap",
  lazy = false,
  config = function()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then return end

    -- Adapter: conectar al debugger remoto de Godot (por defecto 6007)
    dap.adapters.godot = {
      type = "server",
      host = "127.0.0.1",
      port = 6006, 
    }

    -- Configuration para GDScript
    dap.configurations.gdscript = {
      {
        type = "godot",
        request = "launch", --launch or attach
        name = "Attach to Godot (Remote)",
	project = '${workspaceFolder}',
	launch_scene = true,
        -- pathMappings, if you run Godot en otro host/contendor, puedes mapear paths:
        -- pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = "/path/in/container" } },
      },
    }

    -- Opcional: teclas útiles para DAP (puedes cambiar)
    local map = vim.keymap.set
    map("n", "<Leader>5", function() dap.continue() end, { desc = "DAP: Continue/Attach" }) --F5
    map("n", "<Leader>0", function() dap.step_over() end, { desc = "DAP: Step over" }) --F10
    map("n", "<Leader>'", function() dap.step_into() end, { desc = "DAP: Step into" }) --F11
    map("n", "<Leader>¿", function() dap.step_out() end, { desc = "DAP: Step out" }) --F12
    map("n", "<Leader>b", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle breakpoint" })
    map("n", "<Leader>B", function()
	    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') 
    end, { desc = 'Debug: Set Breakpoint'})
    map("n", "<Leader>dr", function() dap.repl.open() end, { desc = "DAP: Open repl" })

    -- Opcional: si quieres UI bonita (instala mfussenegger/nvim-dap and rcarriga/nvim-dap-ui)
    local ok_ui, dapui = pcall(require, "dapui")
    if ok_ui then
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  end,
}
