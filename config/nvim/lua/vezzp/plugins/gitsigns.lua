return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "<leader>gj", gs.next_hunk, "Next Hunk")
      map("n", "<leader>gk", gs.prev_hunk, "Prev Hunk")

      -- Actions
      map("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
      map("v", "<leader>gs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage Hunk")

      map("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
      map("v", "<leader>gr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset Hunk")

      map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")

      map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")

      map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")

      map("n", "<leader>gb", function()
        gs.blame_line({ full = true })
      end, "Blame Line")
      map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle Line Blame")

      map("n", "<leader>gd", gs.diffthis, "Diff This")
      map("n", "<leader>gD", function()
        gs.diffthis("~")
      end, "Diff This ~")
    end,
  },
}
