return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  opts = {
    inlay_hints = { enabled = true },
  },
  config = function()
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

        opts.desc = "Rename With LSP"
        keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

        opts.desc = "Show Documentation Under Cursor"
        keymap.set("n", "<leader>ch", vim.lsp.buf.hover, opts)

        opts.desc = "Show Buffer Diagnostics"
        keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show Line Diagnostics"
        keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts)

        opts.desc = "Go to Prev Diagnostic"
        keymap.set("n", "<leader>dk", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, opts)

        opts.desc = "Go to Next Diagnostic"
        keymap.set("n", "<leader>dj", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, opts)
      end,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.enable("buf_ls")
    vim.lsp.enable("yamlls")
    vim.lsp.enable("ruff")

    vim.lsp.enable("lua_ls")
    vim.lsp.config("lua_ls", {
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

    vim.lsp.enable("sourcekit")
    vim.lsp.config("sourcekit", {
      capabilities = vim.tbl_deep_extend("keep", capabilities, {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      }),
    })

    vim.lsp.enable("gopls")
    vim.lsp.config("gopls", {
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

    vim.lsp.enable("basedpyright")
    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = "basic",
            -- Exclusive Basedpyright options
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

    vim.lsp.enable("clangd")
    vim.lsp.config("clangd", {
      filetypes = { "c", "cpp", "cuda" },
      root_dir = function(fname)
        return require("lspconfig.util").root_pattern(
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja",
          "CMakeLists.txt",
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd"
        )(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
      end,
    })

    vim.lsp.enable("rust_analyzer")
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
        },
      },
    })

    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "󰠠",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "",
        },
      },
    })
  end,
}
