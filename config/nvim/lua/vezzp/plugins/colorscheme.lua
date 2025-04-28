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
        cmp = true,
        gitsigns = true,
        treesitter = true,
        harpoon = true,
        telescope = true,
        mason = true,
        noice = true,
        notify = true,
        which_key = true,
        fidget = true,
        nvimtree = true,
      },
    })
    vim.cmd("colorscheme catppuccin")
  end,
}
