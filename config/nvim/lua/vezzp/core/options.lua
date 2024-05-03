vim.cmd("let g:netrw_liststyle = 3")

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
