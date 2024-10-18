return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
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
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
