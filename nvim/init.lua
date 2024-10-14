-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Disables netrw. Needed for neo-tree hijacking.
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000
    },

    -- firenvim
    { 'glacambre/firenvim', build = ":call firenvim#install(0)" },

    -- # Navigation
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        "3rd/image.nvim",              -- Optional image support in preview window: See `# Preview Mode` for more information
      },
      cmd = "Neotree",
      init = function()
        -- Loads neo-tree when opening neovim as `nvim .`
        vim.api.nvim_create_autocmd('BufEnter', {
          group = vim.api.nvim_create_augroup('NeoTreeInit', { clear = true }),
          callback = function()
            local f = vim.fn.expand('%:p')
            if vim.fn.isdirectory(f) ~= 0 then
              vim.cmd('Neotree current dir=' .. f)
              vim.api.nvim_clear_autocmds { group = 'NeoTreeInit' }
            end
          end
        })
      end,
      keys = {
        {
          "<leader>fe",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd(), reveal = true })
          end,
          desc = "Explorer NeoTree (cwd)",
        },
        { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
        {
          "<leader>ge",
          function()
            require("neo-tree.command").execute({ source = "git_status", toggle = true })
          end,
          desc = "Git Explorer",
        },
      },
      opts = {
        event_handlers = {
          {
            event = "file_open_requested",
            handler = function()
              -- auto close
              -- vim.cmd("Neotree close")
              -- OR
              require("neo-tree.command").execute({ action = "close" })
            end

          }
        },
        source_selector = {
          winbar = true,
        },
        filesystem = {
          hijack_netrw_behavior = 'open_current',
          window = {
            mappings = {
              ["df"] = "diff_files",
              ["tf"] = "telescope_find",
              ["ti"] = "telescope_grep",
              ["o"] = "system_open",
              ['<tab>'] = function(state)
                local node = state.tree:get_node()
                if require("neo-tree.utils").is_expandable(node) then
                  state.commands["toggle_node"](state)
                else
                  state.commands['open'](state)
                  vim.cmd('Neotree reveal')
                end
              end
            },
          },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_hidden = false,
            hide_gitignored = false
          }
        },
        commands = {
          --This implementation is specific to wsl.
          --TODO: Separate into windows-specific configs on refactor
          system_open = function(state)
            local node = state.tree:get_node()
            -- for k, v in pairs(node) do print(k, v) end
            -- Remove node's name out of node's path.
            local path = node:get_id():sub(1, -node.name:len() - 1)
            -- vim.cmd("silent !start explorer" .. p)
            -- wslpath handles converting Linux path to Windows path format and specific path root within our windows fs
            vim.cmd(string.format("!explorer.exe `wslpath -w \"%s\"`", path))
          end,
          telescope_find = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require('telescope.builtin').find_files(getTelescopeOpts(state, path))
          end,
          telescope_grep = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
          end,
          diff_files = function(state)
            local node = state.tree:get_node()
            local log = require("neo-tree.log")
            state.clipboard = state.clipboard or {}
            if diff_Node and diff_Node ~= tostring(node.id) then
              local current_Diff = node.id
              require("neo-tree.utils").open_file(state, diff_Node, open)
              vim.cmd("vert diffs " .. current_Diff)
              log.info("Diffing " .. diff_Name .. " against " .. node.name)
              diff_Node = nil
              current_Diff = nil
              state.clipboard = {}
              require("neo-tree.ui.renderer").redraw(state)
            else
              local existing = state.clipboard[node.id]
              if existing and existing.action == "diff" then
                state.clipboard[node.id] = nil
                diff_Node = nil
                require("neo-tree.ui.renderer").redraw(state)
              else
                state.clipboard[node.id] = { action = "diff", node = node }
                diff_Name = state.clipboard[node.id].node.name
                diff_Node = tostring(state.clipboard[node.id].node.id)
                log.info("Diff source file " .. diff_Name)
                require("neo-tree.ui.renderer").redraw(state)
              end
            end
          end,
        },

      },
    },
    {
      'nvim-telescope/telescope.nvim',
      branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep', 'nvim-treesitter/nvim-treesitter', 'sharkdp/fd' },
      cmd = "Telescope",
      keys = {
        {
          "<leader>ff",
          function()
            require("telescope.builtin").find_files()
          end,
          desc = "Telescope find files"
        },
        {
          "<leader>fb",
          function()
            require("telescope.builtin").buffers()
          end,
          desc = "Telescope search buffers"
        },
        {
          "<leader>fi", -- "find in file"
          function()
            require("telescope.builtin").live_grep()
          end,
          desc = "Telescope live grep"
        }
      }
    },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
      config = function()
        local harpoon = require("harpoon").setup({
          settings = {
            sync_on_ui_close = true,
            save_on_toggle = true
          }
        })
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        vim.keymap.set("n", "<C-d>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)
      end
    },
    {
      "chentoast/marks.nvim",
      event = "VeryLazy",
      opts = {
        builting_marks = { ".", "<", ">", "^" },
      },
    },
    -- # Utility
    {
      "sindrets/diffview.nvim"
    },
    {
      "folke/which-key.nvim",
      dependencies = {
        "echasnovski/mini.icons",
        "nvim-tree/nvim-web-devicons",
      },
      event = "VeryLazy",
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      keys = {
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },
    -- # Editing
    {
      "williamboman/mason.nvim", -- mason.nvim is optimized to load as little as possible during setup. Lazy-loading the plugin, or somehow deferring the setup, is not recommended.
      opts = {}
    },
    {
      "OXY2DEV/markview.nvim",
      lazy = false,      -- Recommended
      -- ft = "markdown" -- If you decide to lazy-load anyway
  
      dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-tree/nvim-web-devicons"
      }
  },
    -- ## LSP
    {"neovim/nvim-lspconfig"},
    {"williamboman/mason-lspconfig.nvim"},
    -- ## DAP
    {"mfussenegger/nvim-dap"},
    {"rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
    -- ## Linting
    {"mfussenegger/nvim-lint"},
    -- ## Formatting
    {"mhartington/formatter.nvim"},
    -- { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- After lazy.vim has been set up, run all post-setup commands.
vim.cmd.colorscheme "catppuccin"

-- Local functions used in commands
function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require "telescope.actions"
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require "telescope.actions.state"
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if (filename == nil) then
          filename = selection[1]
        end
        -- any way to open the file without triggering auto-close event of neo-tree?
        require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
      end)
      return true
    end
  }
end

-- TODO List:
-- which-key seems to require more specific registration for keymappings
-- PROPERLY REGISTER KEY BINDINGS FOR:
-- marks
-- `jk` roll out of insert mode
-- some other roll motion for saving
-- relative number lines
-- 4 space stabs
-- character limit/line length
-- ignore caps search
-- live search/incremental search
