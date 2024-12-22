return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  opts = {
    inlay_hints = { enabled = true },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = false }

        opts.desc = "Show LSP References"
        keymap.set("n", "<leader>cR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to Declaration"
        keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, opts)

        opts.desc = "Go to Definition"
        keymap.set("n", "<leader>cd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP Implementations"
        keymap.set("n", "<leader>ci", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Go to Type Definition"
        keymap.set("n", "<leader>ct", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "Show Available Actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Rename with LSP"
        keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

        opts.desc = "Show Buffer Diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show Line Diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to Previous Diagnostic"
        keymap.set("n", "<leader>xn", vim.diagnostic.goto_prev, opts)
        keymap.set("n", "<leader>x]", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to Next Diagnostic"
        keymap.set("n", "<leader>xp", vim.diagnostic.goto_next, opts)
        keymap.set("n", "<leader>x[", vim.diagnostic.goto_next, opts)

        opts.desc = "Show Documentation under Cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>R", ":LspRestart<CR>", opts)
      end,
    })

    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,

      ["clangd"] = function()
        lspconfig["clangd"].setup({
          filetypes = { "c", "cpp", "cuda" },
          capabilities = capabilities,
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern(
              "CMakeLists.txt",
              "compile_commands.json",
              "compile_flags.txt",
              ".clangd"
            )(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
          end,
        })
      end,

      ["basedpyright"] = function()
        lspconfig["bsedpyright"].setup({
          capabilities = capabilities,
          settings = {
            asedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                -- Exclusive Bsedpyright options
                reportAny = false,
                inlayHints = {
                  -- Common Pyright options
                  variableTypes = true,
                  pytestParameters = true,
                  functionReturnTypes = true,
                },
              },
            },
          },
        })
      end,

      ["gopls"] = function()
        lspconfig["gopls"].setup({
          capabilities = capabilities,
          settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                unreachable = true,
                unusedvariable = true,
                unusedparams = true,
                nilness = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        })
      end,

      ["lua_ls"] = function()
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
              hint = {
                enable = true,
                setType = true,
                paramType = true,
              },
            },
          },
        })
      end,
    })

    lspconfig["buf_ls"].setup({
      filetypes = { "proto" },
      capabilities = capabilities,
    })

    lspconfig["sourcekit"].setup({
      filetypes = { "swift" },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    })
  end,
}
