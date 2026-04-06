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
        row = false,
        col = false,
      },
    },
    picker = {
      enabled = true,
      ui_select = true,
    },
  },
}
