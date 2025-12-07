-- init.lua (o lua/godot_onready.lua)
local M = {}

-- sanitize: quitar caracteres inválidos, dejar solo alfanumérico y _
local function sanitize_name(s)
  s = (s or ""):gsub("[^%w_]", "")
  if s == "" then return "node" end
  -- si empieza con mayúscula, pasar a lowerCamelCase: scoreLabel -> scoreLabel
  s = s:gsub("^%l", string.lower)
  -- si empieza con número, prefijar _
  if s:match("^%d") then s = "_" .. s end
  return s
end

-- obtener texto: prioridad visual selection (si se acaba de yankar), sino clipboard '+', sino register unnamed
local function get_nodepath_from_clipboard_or_register()
  -- preferir selección yanked: register " (unnamed) o +
  local path = vim.fn.getreg('+')
  if path ~= nil and path ~= '' then return path end
  path = vim.fn.getreg('"')
  if path ~= nil and path ~= '' then return path end
  return nil
end

local function infer_name_from_path(path)
  if not path then return "node" end
  local last = path:match("([^/]+)$") or path
  last = last:gsub("^%s+",""):gsub("%s+$","")
  -- quitar sufijos tipo :0 o índices
  last = last:gsub("%:%d+$", "")
  return sanitize_name(last)
end

-- Inserta la línea en la posición actual del cursor (nueva línea encima)
local function insert_onready_line(text)
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- insertar después de la línea actual (row es 1-indexed)
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, {text})
  -- opcional: mover cursor a la variable para editar nombre rápidamente
end

-- función principal
function M.paste_onready(opts)
  -- opts: {type_hint = "Label"} si quieres forzar tipo
  local path = get_nodepath_from_clipboard_or_register()
  if not path or path == "" then
    vim.notify("[godot_onready] No se encontró ruta en el portapapeles ni en el registro.", vim.log.levels.WARN)
    return
  end
  path = path:gsub("\n",""):gsub("\r","") -- limpiar saltos de línea
  -- permitir que el usuario pase rutas con comillas: "HUD/ScoreLabel"
  path = path:gsub('^"(.*)"$','%1')
  local name = infer_name_from_path(path)
  local typ = opts and opts.type_hint or "Node" -- por defecto Node; puedes pasar un tipo
  local line = string.format("@onready var %s: %s = $%s", name, typ, path)
  insert_onready_line(line)
  vim.notify("[godot_onready] Insertado: " .. line, vim.log.levels.INFO)
end

-- Helper para comprobar conflictos de mapping
local function check_mapping_conflict(lhs, mode)
  local maps = vim.api.nvim_get_keymap(mode or "n")
  for _, m in ipairs(maps) do
    if m.lhs == lhs then
      return m
    end
  end
  return nil
end

-- Registrar mappings: <leader>gp para insertar; en visual también permite usar selección (yank previo)
local function setup_mappings()
  local lhs = "<leader>go"
  local conflict = check_mapping_conflict(lhs, "n")
  if conflict then
    vim.notify(string.format("[godot_onready] Atención: ya existe mapping para %s -> %s", lhs, conflict.rhs or "<lua>"), vim.log.levels.WARN)
  end

  -- normal mode
  vim.keymap.set('n', lhs, function()
    M.paste_onready() -- por defecto Type=Node; puedes llamar con M.paste_onready({type_hint="Label"})
  end, {desc = "Godot: pegar @onready desde clipboard (ruta de nodo)", noremap=true})

  -- visual mode: primero yank a register + y luego invocar la misma función
  vim.keymap.set('v', lhs, function()
    -- yankar selección al portapapeles + para que getreg lo encuentre
    vim.cmd('normal! "+y')
    M.paste_onready()
    -- salir de visual (opcional)
    vim.cmd('normal! gv')
  end, {desc = "Godot: yank selección y pegar @onready", noremap=true})
end

M.setup = function()
  setup_mappings()
end

return M
