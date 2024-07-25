return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open Trouble Workspace Diagnostics" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Open Trouble Document Diagnostics" },
    { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open Trouble Quickfix List" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open Trouble Location List" },
    { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open Todos in Trouble" },
  },
}
