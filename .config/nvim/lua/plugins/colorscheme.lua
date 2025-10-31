return {
  -- Disable the default colorscheme
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },

  -- Add Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato", -- latte (light), frappe, macchiato, mocha (dark)
      background = { -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true, -- Use terminal background
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      color_overrides = {},
      custom_highlights = function(colors)
        return {
          -- Override specific highlights to ensure transparency
          Normal = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          LineNr = { bg = "NONE" },
          CursorLineNr = { bg = "NONE" },
          TelescopeNormal = { bg = "NONE" },
          TelescopeBorder = { bg = "NONE" },
        }
      end,
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)

      -- Additional transparency fixes after colorscheme is loaded
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Force transparency for these highlight groups
          local highlights = {
            "Normal",
            "NormalFloat",
            "SignColumn",
            "LineNr",
            "CursorLineNr",
            "TelescopeNormal",
            "TelescopeBorder",
            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "NvimTreeNormal",
            "WhichKeyFloat",
            "NotifyBackground",
          }

          for _, highlight in ipairs(highlights) do
            vim.cmd(string.format("highlight %s guibg=NONE ctermbg=NONE", highlight))
          end
        end,
      })
    end,
  },
}
