local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
-- plugins
{
    {
        "folke/tokyonight.nvim",
        lazy = false,
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = "dark",
                    floats = "dark",
                },
            })
        end
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        config = function()
            vim.cmd("colorscheme rose-pine")
            -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    },
    {
        "nvim-lua/plenary.nvim",
        name = "plenary",
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "plenary" },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
            vim.keymap.set('n', '<leader>pws', function()
                local word = vim.fn.expand('<cword>')
                builtin.grep_string({ search = word })
            end)
            vim.keymap.set('n', '<leader>pWs', function()
                local word = vim.fn.expand('<cWORD>')
                builtin.grep_string({ search = word })
            end)
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = { "bash", "c", "cpp", "css", "html", "java", "javascript", "json", "lua", "python", "scss", "typescript", "vim", "vimdoc" },
                sync_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                --indent = { enable = false },
            })
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "folke/zen-mode.nvim",
        config = function()
            vim.keymap.set("n", "<leader>zz", function()
                require("zen-mode").setup({
                    window = {
                        width = 90,
                        options = { }
                    },
                })
                require("zen-mode").toggle()
                vim.wo.wrap = false
                vim.wo.number = true
                vim.wo.rnu = true
            end)

            vim.keymap.set("n", "<leader>zZ", function()
                require("zen-mode").setup({
                    window = {
                        width = 80,
                        options = { }
                    },
                })
                require("zen-mode").toggle()
                vim.wo.wrap = false
                vim.wo.number = false
                vim.wo.rnu = false
                vim.opt.colorcolumn = "0"
            end)
        end
    },
    {
        "laytan/cloak.nvim",
        config = function()
            require("cloak").setup({
                enabled = true,
                cloak_character = '*',
                -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
                highlight_group = 'Comment',
                -- Applies the length of the replacement characters for all matched
                -- patterns, defaults to the length of the matched pattern.
                cloak_length = nil, -- Provide a number if you want to hide the true length of the value.
                -- Wether it should try every pattern to find the best fit or stop after the first.
                try_all_patterns = true,
                patterns = {
                    {
                        -- Match any file starting with '.env'.
                        -- This can be a table to match multiple file patterns.
                        file_pattern = '.env*',
                        -- Match an equals sign and any character after it.
                        -- This can also be a table of patterns to cloak,
                        -- example: cloak_pattern = { ':.+', '-.+' } for yaml files.
                        cloak_pattern = '=.+',
                        -- A function, table or string to generate the replacement.
                        -- The actual replacement will contain the 'cloak_character'
                        -- where it doesn't cover the original text.
                        -- If left emtpy the legacy behavior of keeping the first character is retained.
                        replace = nil,
                    },
                },
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp"
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "angularls", "tsserver" },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({ on_attach = attach })
                    end
                },
                automatic_installation = true,
            })

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', '<C-h>', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set('n', '<space>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<space>f', function()
                        vim.lsp.buf.format { async = true }
                    end, opts)
                end
            })

            local cmp = require('cmp')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ['<Tab>'] = nil,
                    ['<S-Tab>'] = nil,
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' }
                },{
                    { name = 'buffer' }
                }),
            })
            local cmp_select = {behavior = cmp.SelectBehavior.Select}

            --vim.diagnostic.config({ virtual_text = true })
        end
    },
    {
        "folke/trouble.nvim",
        config = function()
            local trouble = require("trouble")
            trouble.setup({
                icons = false,
            })

            vim.keymap.set("n", "<leader>tt", function()
                trouble.toggle()
            end)

            vim.keymap.set("n", "]d", function()
                trouble.next({ skip_groups = true, jump = true })
            end)

            vim.keymap.set("n", "[d", function()
                trouble.previous({ skip_groups = true, jump = true })
            end)
        end
    },
}, 
-- options
{})
