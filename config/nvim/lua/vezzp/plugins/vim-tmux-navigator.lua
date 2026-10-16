-- Window-split navigation chords for standalone tmux and bare nvim, via
-- christoomey/vim-tmux-navigator. The herdr case lives next door:
-- config/nvim/lua/vezzp/plugins/vim-herdr-navigator.lua.
--
-- Ownership contract for the plain <C-h/j/k/l> chords:
-- · When the herdr editor side is installed, IT owns the chords (nvim splits
--   + handoff into herdr panes at the edges). This plugin then only provides
--   the TmuxNavigate* commands — the herdr editor's tmux fallback and the
--   <C-\> (last split) mapping call into them.
-- · Without the herdr editor side, this plugin's own stock mappings stay
--   enabled and cover tmux (tmux-aware at edges) and bare nvim (wincmd).
--
-- Do NOT register the chords in a `keys` list here: lazy applies `keys`
-- after the herdr spec's config runs, so an unconditional keys list would
-- clobber the herdr editor's maps again (all four chords degraded to plain
-- wincmd, no handoff — the j/k-dead regression from Oct 2025).
--
-- The netrw <C-l> workaround is disabled: its rhs was the source of an E492
-- on a stale session, and this config uses nvim-tree/snacks, not netrw.

local herdr_editor = require("vezzp.herdr_editor").editor()

return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    if herdr_editor ~= "" then
      vim.g.tmux_navigator_no_mappings = 1
    end
    vim.g.tmux_navigator_disable_netrw_workaround = 1
  end,
}
