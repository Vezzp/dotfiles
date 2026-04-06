return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = {
      enabled = true,
      win = {
        style = "input",
        relative = "editor",
        row = 0.5,
        col = 0.5,
      },
    },
    picker = {
      enabled = true,
      ui_select = true,
    },
  },
}
