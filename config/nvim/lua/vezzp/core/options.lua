local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.tabstop = 2
opt.shiftwidth = 2

-- expand tab to spaces
opt.expandtab = true

-- copy indent from current line when starting the new one
opt.autoindent = true

opt.wrap = false

-- ignore case during search
opt.ignorecase = true

-- mixed cases stops ignoring the cases
opt.smartcase = true

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

-- use system clipboard as a default register
opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

-- hide the command-line row: the statusline sits flush at the bottom, and
-- the cmdline expands as an overlay over it only while typing a command
-- (snacks.input already floats all prompts)
opt.cmdheight = 0

opt.termsync = true

if
  (vim.env.SSH_TTY or vim.env.XDG_SESSION_TYPE == "tty" or (vim.fn.has("unix") and vim.env.XDG_SESSION_TYPE == nil))
  and vim.env.TMUX == nil
then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

-- herdr-style gaps between windows: blank separator cells showing the
-- terminal background instead of drawn lines. Neovim's gap is fixed at one
-- cell wide; there is no native way to make it wider.
opt.fillchars:append({
  vert = " ",
  vertleft = " ",
  vertright = " ",
  verthoriz = " ",
  horiz = " ",
  horizup = " ",
  horizdown = " ",
  eob = " ",
  foldsep = " ",
})
local function clear_win_separator_bg()
  vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })
end
clear_win_separator_bg()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("vezzp-win-separator-gap", { clear = true }),
  callback = clear_win_separator_bg,
})
