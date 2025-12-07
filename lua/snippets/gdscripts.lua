-- snippets/gdscript.lua (LuaSnip)
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("onready", {
    t("@onready var "), i(1, "name"), t(": "), i(2, "Node"), t(" = $"), i(3, "Path")
  }),
  -- snippet corto para $Path
  s("dollar", {
    t("$"), i(1, "Path")
  }),
}
