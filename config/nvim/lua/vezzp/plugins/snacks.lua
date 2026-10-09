return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    -- snacks.dashboard hides tabline/statusline while it is shown (hardcoded
    -- zeroing in M.setup, no opt-out). Restore the normal chrome when the
    -- dashboard opens. SnacksDashboardOpened fires after the zeroing, and the
    -- internal restore() only re-applies values that are 0, so this coexists
    -- with it instead of fighting it.
    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardOpened",
      callback = function()
        vim.o.showtabline, vim.o.laststatus = 2, 3
      end,
    })
  end,
  opts = {
    input = {
      enabled = true,
      win = {
        style = "input",
        relative = "editor",
        row = false,
        col = false,
      },
    },
    picker = {
      enabled = true,
      ui_select = true,
      layout = { preset = "telescope" },
    },
    indent = {
      enabled = true,
    },
    toggle = {
      notify = false, -- no "Enabled **Zen Mode**"-style messages
    },
    zen = {
      -- no backdrop dimming (grayscale) and keep signs visible
      toggles = { dim = false, git_signs = true },
      show = { statusline = true, tabline = true },
      win = {
        wo = { number = true, relativenumber = true, cursorline = true },
      },
    },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
      preset = {
        header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        keys = {
          -- { icon = " ", key = "e", desc = "New File", action = ":ene" },
          -- { icon = " ", key = "SPC e", desc = "Toggle File Explorer", action = ":NvimTreeFindFileToggle" },
          -- { icon = " ", key = "SPC ff", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          -- { icon = " ", key = "SPC sg", desc = "Find Word", action = ":lua Snacks.dashboard.pick('live_grep')" },
          -- { icon = " ", key = "q", desc = "Quit Neovim", action = ":qa" },
        },
      },
    },
  },
}
