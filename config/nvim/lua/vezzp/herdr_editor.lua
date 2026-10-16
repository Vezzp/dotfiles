-- Shared detection for the herdr-provided vim-herdr-navigation editor side.
--
-- Both plugin specs need this answer, for different reasons:
-- · config/nvim/lua/vezzp/plugins/vim-herdr-navigator.lua loads the editor
--   side from the path and hands it the chords;
-- · config/nvim/lua/vezzp/plugins/vim-tmux-navigator.lua suppresses its own
--   stock <C-h/j/k/l> mappings when the editor side owns them.
-- Keeping the glob here means there is exactly one place that knows how the
-- herdr plugin is laid out on disk.

local M = {}

--- Absolute path of the newest installed editor/nvim.lua, or "" when the
--- herdr plugin is not installed (e.g. herdr-less machines sharing this config).
function M.editor()
  local hits = vim.fn.globpath(
    vim.fn.expand("~/.config/herdr/plugins/github"),
    "vim-herdr-navigation-*/editor/nvim.lua",
    false,
    true
  )
  table.sort(hits)
  return hits[#hits] or ""
end

return M
