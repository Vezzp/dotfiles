return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local comment = require("Comment")

    local keymap = vim.keymap
    keymap.set("n", "<leader>/", function()
      require("Comment.api").toggle.linewise.current()
    end, { desc = "comment toggle" })

    comment.setup()
  end,
}
