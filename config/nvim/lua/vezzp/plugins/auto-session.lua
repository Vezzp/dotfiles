return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore_enabled = false,
      auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>qr", "<cmd>SessionRestore<CR>", { desc = "Restore Session" })
    keymap.set("n", "<leader>qs", "<cmd>SessionSave<CR>", { desc = "Save Session" })
  end,
}
