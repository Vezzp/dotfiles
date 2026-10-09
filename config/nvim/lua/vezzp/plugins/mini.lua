return {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.align").setup({
      mappings = {
        start = "ga",
        start_with_preview = "gA",
      },
    })

    -- replaces nvim-autopairs; blink's auto_brackets covers completion accept
    require("mini.pairs").setup({})
  end,
}
