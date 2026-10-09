return {
  "saghen/blink.cmp",
  -- eager: get_lsp_capabilities() is required from lspconfig at BufReadPre,
  -- before blink's own InsertEnter lazy-load would fire
  lazy = false,
  version = "1.*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      preset = "default",
      -- parity with the previous nvim-cmp mapping set
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      -- parity with cmp completeopt "menu,menuone,preview,noselect"
      -- and <CR> confirm({ select = false }): nothing is accepted unless
      -- explicitly highlighted, no auto-insert while typing
      list = { selection = { preselect = false, auto_insert = false } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = {
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
    },
    snippets = { preset = "default" }, -- native vim.snippet expansion
    sources = {
      default = { "lsp", "snippets", "buffer", "path" },
    },
  },
}
