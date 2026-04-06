return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = {
      enabled = true,
      win = {
        style = "input",
        relative = "editor",
        row = 0.5,
        col = 0.5,
      },
    },
    picker = {
      enabled = true,
      ui_select = true,
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    local group = vim.api.nvim_create_augroup("VezzpSnacksInput", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "snacks_input",
      callback = function()
        vim.schedule(function()
          if vim.bo.buftype == "prompt" then
            vim.cmd("stopinsert")
          end
        end)
      end,
    })
  end,
}
