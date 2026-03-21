return {
  {
    "echasnovski/mini.indentscope",
    version = "v0.17.*",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  {
    "echasnovski/mini.align",
    version = "v0.17.*",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      mappings = {
        start = "ga",
        start_with_preview = "gA",
      },
    },
  },
}
