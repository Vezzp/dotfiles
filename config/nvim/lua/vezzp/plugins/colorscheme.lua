return {
  "catppuccin/nvim",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "auto",
      term_colors = true,
      transparent_background = true,
      background = {
        light = "latte",
        dark = "frappe",
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        treesitter = true,
        snacks = true,
        mason = true,
        noice = true,
        which_key = true,
        nvimtree = true,
      },
    })
    vim.cmd("colorscheme catppuccin")
  end,
}
