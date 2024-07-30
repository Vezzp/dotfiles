return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      modules = {},
      auto_install = true,
      ignore_install = {},
      sync_install = false,
      highlight = {
        enable = true,
      },
      indent = { enable = true },
      autotag = {
        enable = true,
      },
      ensure_installed = {
        "json",
        "yaml",
        "html",
        "toml",
        "markdown",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "c",
        "cpp",
        "cuda",
        "rust",
        "go",
        "gomod",
        "make",
        "cmake",
        "python",
        "latex",
        "proto",
        "bash",
      },
    })
  end,
}
