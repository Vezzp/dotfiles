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
      { "<leader>f", desc = "+file/find" },
      { "<leader>w", desc = "+windows" },
      { "<leader><tab>", desc = "+tabs" },
      { "<leader>c", desc = "+code" },
      { "<leader>s", desc = "+search" },
      { "<leader>x", desc = "+diagnostics/quickfix" },
      { "<leader>q", desc = "+quit/session" },
      { "<leader>r", desc = "+rename" },
    }, {})
  end,
}
