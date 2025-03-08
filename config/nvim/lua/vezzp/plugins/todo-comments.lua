return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  lazy = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local todo_comments = require("todo-comments")

    local keymap = vim.keymap

    keymap.set("n", "mlt", function()
      todo_comments.jump_next()
    end, { desc = "Go to Next TODO Comment" })

    keymap.set("n", "mht", function()
      todo_comments.jump_prev()
    end, { desc = "Go to Prev TODO Comment" })

    todo_comments.setup()
  end,
}
