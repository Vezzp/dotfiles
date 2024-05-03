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
    defaults = {
      ["<leader>f"] = { "+file/find" },
      ["<leader>w"] = { "+windows" },
      ["<leader><tab>"] = { "+tabs" },
      ["<leader>c"] = { "+code" },
      ["<leader>s"] = { "+search" },
      ["<leader>x"] = { "+diagnostics/quickfix" },
      ["<leader>q"] = { "+quit/session" },
      ["<leader>r"] = { "+rename" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
