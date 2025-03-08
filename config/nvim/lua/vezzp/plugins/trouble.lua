return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
  },
  cmd = "Trouble",
  keys = {
    { "<leader>dw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open Trouble Workspace Diagnostics" },
    { "<leader>dt", "<cmd>Trouble todo toggle<CR>", desc = "Open TODOs in Trouble" },
  },
}
