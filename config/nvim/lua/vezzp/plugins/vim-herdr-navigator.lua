-- Pane navigation inside herdr, via the herdr-provided plugin
-- paulbkim-dev/vim-herdr-navigation (installed herdr-side via
-- `herdr plugin install`): plain ctrl+h/j/k/l move panes herdr-wide and get
-- forwarded into Vim when it is the foreground pane — the herdr mirror of
-- tmux's root binds. This spec loads the plugin's editor side, which handles
-- Vim splits + edge handoff (falling back to the tmux navigator's commands or
-- plain wincmd outside herdr panes).
--
-- The tmux navigator plugin and the chord-ownership contract live in
-- config/nvim/lua/vezzp/plugins/vim-tmux-navigator.lua; the shared "is the
-- herdr editor installed?" check lives in lua/vezzp/herdr_editor.lua.
--
-- Load the editor side so it wins over other <C-h/j/k/l> mappings (e.g.
-- vim-tmux-navigator): dofile is the simplest reliable way, see the plugin's
-- README for the after/plugin alternative.

local herdr_editor = require("vezzp.herdr_editor").editor()

return {
  {
    dir = herdr_editor ~= "" and vim.fn.fnamemodify(herdr_editor, ":h:h:h") or "~/src/vim-herdr-navigation",
    name = "vim-herdr-navigation",
    enabled = herdr_editor ~= "",
    config = function()
      dofile(herdr_editor)
      -- The editor side maps only <C-h/j/k/l>. When it owns the chords, the
      -- plugin's own <C-\> (last split) map is suppressed too, so restore it
      -- here on the tmux navigator command: plain wincmd p inside herdr,
      -- tmux-aware in tmux. (Herdr's last-pane replacement is prefix+;.)
      vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true })
    end,
  },
}
