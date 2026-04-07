return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")

    -- Use git instead of curl for downloading parsers (more reliable)
    require("nvim-treesitter.install").prefer_git = true

    local parsers = {
      "json",
      "yaml",
      "html",
      "toml",
      "markdown",
      "markdown_inline",
      "bash",
      "lua",
      "vim",
      "vimdoc",
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
    }

    treesitter.install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        if vim.treesitter.language.get_lang(vim.bo.filetype) then
          pcall(vim.treesitter.start)
        end
      end,
    })
  end,
}
