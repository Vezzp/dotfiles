return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  lazy = true,
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "ruff" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Lint" })
  end,
}
