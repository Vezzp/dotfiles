return {
  "folke/which-key.nvim",
  lazy = true,
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    preset = "helix",
    delay = 300,
    icons = {
      separator = "·",
      mappings = false, -- no icons on mappings, neither explicit nor from rules
    },
    win = {
      border = "rounded",
      title = true,
      title_pos = "center",
    },
    plugins = { spelling = true },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>f", desc = "+file/find" },
      { "<leader>w", desc = "+windows" },
      { "<leader><tab>", desc = "+tabs" },
      { "<leader>c", desc = "+code" },
      { "<leader>s", desc = "+search" },
      { "<leader>d", desc = "+diagnostics" },
      { "<leader>q", desc = "+quit/session" },
      { "<leader>r", desc = "+rename" },
      { "<leader>g", desc = "+git" },
      { "m", desc = "+move", group = "move" },
    }, {})
  end,
}
