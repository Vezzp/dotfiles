return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      options = {
        number = true,
        relativenumber = true,
        cursorline = true,
      },
    },
    plugins = {
      twilight = { enabled = false },
      options = {
        gitsigns = true,
        ruler = true,
      },
    },
  },
}
