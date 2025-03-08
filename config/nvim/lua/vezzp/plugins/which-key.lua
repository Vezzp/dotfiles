return {
  "folke/which-key.nvim",
  lazy = true,
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    plugins = { spelling = true },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>f", desc = "+file/find", icon = "󰈞" },
      { "<leader>w", desc = "+windows" },
      { "<leader><tab>", desc = "+tabs" },
      { "<leader>c", desc = "+code" },
      { "<leader>s", desc = "+search" },
      { "<leader>d", desc = "+diagnostics" },
      { "<leader>q", desc = "+quit/session" },
      { "<leader>r", desc = "+rename", icon = "󰙩" },
      { "<leader>g", desc = "+git" },
      { "m", desc = "+move", icon = "󰆾", group = "move" },
    }, {})
  end,
}
