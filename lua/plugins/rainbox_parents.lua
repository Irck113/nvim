return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "VeryLazy",
  config = function()
    local rd = require("rainbow-delimiters")
    vim.g.rainbow_delimiters = {

      strategy = {
        [""]  = rd.strategy["global"],
        lua   = rd.strategy["local"],
        vim   = rd.strategy["local"],
        javascript = rd.strategy["local"],
        typescript = rd.strategy["local"],
        html = rd.strategy["local"],
	rust = rd.strategy["local"],
      },
      query = {
        [""] = "rainbow-delimiters",
        --lua = "rainbow-delimiters",
        --javascript = "rainbow-delimiters",
        --typescript = "rainbow-delimiters",
        --html = "rainbow-delimiters",
	--rust = "rainbow-delimiters",
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
