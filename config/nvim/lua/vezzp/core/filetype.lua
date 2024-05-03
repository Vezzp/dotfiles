local ft = vim.filetype
if not ft then
  return
end

ft.add({
  pattern = {
    [".*#!.*bash.*"] = "bash",
    [".*#!.*zsh.*"] = "zsh",
  },
})
