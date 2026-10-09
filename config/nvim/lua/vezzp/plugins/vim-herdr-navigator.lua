-- Pane navigation for herdr and standalone tmux, via upstream plugins.
-- You switch between herdr and standalone tmux (never nested: don't run tmux
-- inside herdr or vice versa).
--
-- · herdr: paulbkim-dev/vim-herdr-navigation — installed herdr-side via
--   `herdr plugin install` (plain ctrl+h/j/k/l move panes herdr-wide and get
--   forwarded into Vim when it is the foreground pane); this spec loads its
--   editor side, which handles Vim splits + edge handoff and falls back to
--   tmux or plain wincmd outside herdr panes.
-- · tmux: christoomey/vim-tmux-navigator provides the commands; its stock
--   mappings stay enabled only on machines where the herdr editor side is
--   absent, otherwise the two plugins would fight over the chords.

local function herdr_nav_editor()
  local hits = vim.fn.globpath(
    vim.fn.expand("~/.config/herdr/plugins/github"),
    "vim-herdr-navigation-*/editor/nvim.lua",
    false,
    true
  )
  table.sort(hits)
  return hits[#hits] or ""
end

local editor = herdr_nav_editor()

return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      -- the herdr editor side owns the chords when it is present
      if editor ~= "" then
        vim.g.tmux_navigator_no_mappings = 1
      end
      -- netrw's <C-l> user-map workaround is useless here (nvim-tree/snacks,
      -- not netrw) and its rhs was the source of an E492 on a stale session
      vim.g.tmux_navigator_disable_netrw_workaround = 1
    end,
  },
  {
    dir = editor ~= "" and vim.fn.fnamemodify(editor, ":h:h:h") or "~/src/vim-herdr-navigation",
    name = "vim-herdr-navigation",
    enabled = editor ~= "",
    config = function()
      dofile(editor)
    end,
  },
}
