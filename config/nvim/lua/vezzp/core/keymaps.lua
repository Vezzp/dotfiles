vim.g.mapleader = " "

local keymap = vim.keymap

-- buffer management
keymap.set("n", "<leader>w|", "<C-w>v", { desc = "Split Window Vertically" })
keymap.set("n", "<leader>w-", "<C-w>s", { desc = "Split Window Horizontally" })
keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize Split Window Size" })
keymap.set("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close Current Window" })
keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Next Window" })
keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Prev Window" })
keymap.set("n", "<leader>wr", "<cmd>e %<CR>", { desc = "Reload Current Window" })

-- tab management
keymap.set("n", "<leader><Tab><Tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
keymap.set("n", "<leader><Tab>x", "<cmd>tabclose<CR>", { desc = "Close Current Tab" })

keymap.set("n", "<leader><Tab>l", "<cmd>tabn<CR>", { desc = "Next Tab" })
keymap.set("n", "<leader><Tab>h", "<cmd>tabp<CR>", { desc = "Prev Tab" })

keymap.set("n", "<leader><Tab>w", "<cmd>tabnew %<CR>", { desc = "Open Current Window in Tab" })

-- renaming
-- https://www.reddit.com/r/neovim/comments/14ej2pa/comment/jp3dz5m/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
keymap.set("n", "<leader>rw", ":%s/<C-r><C-w>//g<left><left>", { desc = "Rename Word (Window)" })

vim.keymap.set("n", "<leader>rW", function()
  return ":" .. vim.fn.line(".") .. "s/<C-r><C-w>//g<left><left>"
end, { expr = true, desc = "Rename Word (Line)" })

vim.keymap.set("n", "<leader>rc", function()
  local clipboard = vim.fn.getreg("*")
  return ":%s/" .. clipboard .. "//gc<left><left><left>"
end, { expr = true, desc = "Rename Clipboard Sequence (Window)" })

vim.keymap.set("n", "<leader>rC", function()
  local clipboard = vim.fn.getreg("*")
  return ":" .. vim.fn.line(".") .. "s/" .. clipboard .. "//g<left><left>"
end, { expr = true, desc = "Rename Clipboard Sequence (Line)" })

-- lsp inlay hints since neovim 0.10.0
if vim.lsp.inlay_hint then
  keymap.set("n", "<leader>cH", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
  end, { desc = "Toggle Inlay Hints" })
end

vim.keymap.set("n", "<leader>tl", function()
  vim.o.background = "light"
end, { desc = "Switch to Light Theme" })

vim.keymap.set("n", "<leader>td", function()
  vim.o.background = "dark"
end, { desc = "Switch to Dark Theme" })

vim.keymap.set("n", "<leader>tt", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end, { desc = "Toggle Inverted Theme" })

vim.keymap.set("n", "<leader>ts", "<cmd>Telescope colorscheme<cr>", { desc = "Find Theme" })
