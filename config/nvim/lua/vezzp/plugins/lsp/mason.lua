return {
  "williamboman/mason.nvim",
  dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- LSP servers activate via vim.lsp.enable (lspconfig.lua), binaries are
    -- resolved from PATH (mason prepends its bin dir here). Registry names,
    -- not lspconfig server names.
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP servers
        "lua-language-server",
        "basedpyright",
        "yaml-language-server",
        "buf",
        -- formatters / linters
        "stylua",
        "shfmt",
        "ruff",
        "tex-fmt",
      },
    })
  end,
}
