-- This file can be loaded by calling `lua require('plugins')` from your init.vim


-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]


return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use "nvim-lua/plenary.nvim"
    use {
        'jose-elias-alvarez/null-ls.nvim',
        config = function()
            require("null-ls").setup()
        end,
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use { "catppuccin/nvim", as = "catppuccin" }
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = { { "nvim-lua/plenary.nvim" } }
    }
    use('mbbill/undotree')
    use('tpope/vim-fugitive')
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            --- Uncomment the two plugins below if you want to manage the language servers from neovim
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },


            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            -- Autocompletion

            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },

            { 'L3MON4D3/LuaSnip' },
            -- ThePrimeagen setup needs
            { 'rafamadriz/friendly-snippets' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-buffer' },
            { 'saadparwaiz1/cmp_luasnip' },

        }
    }
    use {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        requires = {
            'williamboman/mason.nvim'
        },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    -- C++
                    'codelldb',
                    -- Python
                    'mypy', 'ruff', 'black', 'debugpy' }
            })
        end
    }
    use 'mfussenegger/nvim-dap'
    use {
        'mfussenegger/nvim-dap-python',
        ft = 'python',
        requires = {
            'mfussenegger/nvim-dap',
        },
        config = function(_, opts)
            local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
            require("dap-python").setup(path)
        end
    }
    use "jay-babu/mason-nvim-dap.nvim"
    use { "rcarriga/nvim-dap-ui",
        requires = { "mfussenegger/nvim-dap" },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end
    }
end)
