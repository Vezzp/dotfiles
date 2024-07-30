return {
  "catppuccin/nvim",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "auto",
      background = {
        light = "latte",
        dark = "frappe",
      },
      integrations = {
        noice = true,
        telescope = true,
        nvimtree = true,
      },
    })
    vim.cmd("colorscheme catppuccin")
  end,
}
