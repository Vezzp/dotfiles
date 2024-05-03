vim.g.mapleader = " "

local keymap = vim.keymap

-- buffer management
keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split Window Vertically" })
keymap.set("n", "<leader>w|", "<C-w>v", { desc = "Split Window Vertically" })

keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split Window Horizontally" })
keymap.set("n", "<leader>w-", "<C-w>s", { desc = "Split Window Horizontally" })

keymap.set("n", "<leader>we", "<C-w>=", { desc = "Equalize Split Window Size" })
keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize Split Window Size" })

keymap.set("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close Current Window" })

-- tab management
keymap.set("n", "<leader><Tab><Tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
keymap.set("n", "<leader><Tab>x", "<cmd>tabclose<CR>", { desc = "Close Current Tab" })

keymap.set("n", "<leader><Tab>n", "<cmd>tabn<CR>", { desc = "Next Tab" })
keymap.set("n", "<leader><Tab>]", "<cmd>tabn<CR>", { desc = "Next Tab" })

keymap.set("n", "<leader><Tab>p", "<cmd>tabp<CR>", { desc = "Previous Tab" })
keymap.set("n", "<leader><Tab>[", "<cmd>tabp<CR>", { desc = "Previous Tab" })

keymap.set("n", "<leader><Tab>w", "<cmd>tabnew %<CR>", { desc = "Open Current Window in Tab" })

-- renaming
-- https://www.reddit.com/r/neovim/comments/14ej2pa/comment/jp3dz5m/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
keymap.set({ "n" }, "<leader>rw", ":%s/<C-r><C-w>//g<left><left>", { desc = "Rename Word (Window)" })

vim.keymap.set({ "n", "v" }, "<leader>rW", function()
  return ":" .. vim.fn.line(".") .. "s/<C-r><C-w>//g<left><left><C-h>"
end, { expr = true, desc = "Rename Word (Line)" })
