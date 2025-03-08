return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  enabled = true,
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["a="] = { query = "@assignment.outer", desc = "Select Outer Assignment Part" },
            ["i="] = { query = "@assignment.inner", desc = "Select Inner Assignment Part" },
            ["l="] = { query = "@assignment.lhs", desc = "Select LHS Assignment Part" },
            ["r="] = { query = "@assignment.rhs", desc = "Select RHS Assignment Part" },

            ["aa"] = { query = "@parameter.outer", desc = "Select Outer Argument Part" },
            ["ia"] = { query = "@parameter.inner", desc = "Select Inner Argument Part" },

            ["ai"] = { query = "@conditional.outer", desc = "Select Outer Conditional Part" },
            ["ii"] = { query = "@conditional.inner", desc = "Select Inner Conditional Part" },

            ["al"] = { query = "@loop.outer", desc = "Select Outer Loop Part" },
            ["il"] = { query = "@loop.inner", desc = "Select Inner Loop Part" },

            ["ac"] = { query = "@call.outer", desc = "Select Outer Function Call Part" },
            ["ic"] = { query = "@call.inner", desc = "Select Inner Function Call Part" },

            ["af"] = { query = "@function.outer", desc = "Select Outer Function Part" },
            ["if"] = { query = "@function.inner", desc = "Select Inner Function Part" },

            ["as"] = { query = "@class.outer", desc = "Select Outer Class Part" },
            ["is"] = { query = "@class.inner", desc = "Select Inner Class Part" },

            ["a/"] = { query = "@comment.outer", desc = "Select Outer Comment Part" },
            ["i/"] = { query = "@comment.inner", desc = "Select Inner Comment Part" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["mspl"] = { query = "@parameter.outer", desc = "Swap Next Parameter with Current" },
            ["msfl"] = { query = "@function.outer", desc = "Swap Next Function with Current" },
          },
          swap_previous = {
            ["msph"] = { query = "@parameter.outer", desc = "Swap Prev Parameter with Current" },
            ["msfh"] = { query = "@function.outer", desc = "Swap Prev Function with Current" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["mlck"] = { query = "@call.outer", desc = "Go to Next Function Call Start" },
            ["mlfk"] = { query = "@function.outer", desc = "Go to Next Function Def Start" },
            ["mlsk"] = { query = "@class.outer", desc = "Go to Next Struct Start" },
            ["mlik"] = { query = "@conditional.outer", desc = "Go to Next Conditional Start" },
            ["mllk"] = { query = "@loop.outer", desc = "Go to Next Loop Start" },
          },
          goto_next_end = {
            ["mlcj"] = { query = "@call.outer", desc = "Go to Next Function Call End" },
            ["mlfj"] = { query = "@function.outer", desc = "Go to Next Function Def End" },
            ["mlsj"] = { query = "@class.outer", desc = "Go to Next Struct End" },
            ["mlij"] = { query = "@conditional.outer", desc = "Go to Next Conditional End" },
            ["mllj"] = { query = "@loop.outer", desc = "Go to Next Loop End" },
          },
          goto_previous_start = {
            ["mhck"] = { query = "@call.outer", desc = "Go to Prev Function Call Start" },
            ["mhfk"] = { query = "@function.outer", desc = "Go to Prev Function Def Start" },
            ["mhsk"] = { query = "@class.outer", desc = "Go to Prev Struct Start" },
            ["mhik"] = { query = "@conditional.outer", desc = "Go to Prev Conditional Start" },
            ["mhlk"] = { query = "@loop.outer", desc = "Go to Prev Loop Start" },
          },
          goto_previous_end = {
            ["mhcj"] = { query = "@call.outer", desc = "Go to Prev Function Call End" },
            ["mhfj"] = { query = "@function.outer", desc = "Go to Prev Function Def End" },
            ["mhsj"] = { query = "@class.outer", desc = "Go to Prev Struct End" },
            ["mhij"] = { query = "@conditional.outer", desc = "Go to Prev Conditional End" },
            ["mhlj"] = { query = "@loop.outer", desc = "Go to Prev Loop End" },
          },
        },
      },
    })
  end,
}
