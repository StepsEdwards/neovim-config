local M = {
    -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            -- NOTE: If you are having trouble with this installation,
            -- refer to the README for telescope-fzf-native for more instructions.
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
    },
    config = function()
        -- Enable telescope fzf native, if installed
        pcall(require('telescope').load_extension, 'fzf')
    end,
    keys = {
        -- See `:help telescope_builtin`
        {
            desc = '[?] Find recently opened files',
            mode = { 'n' },
            '<leader>?', function()
                require('telescope.builtin').oldfiles()
            end
        },
        {
            '<leader><leader>', mode = { 'n' },
            function()
                require('telescope.builtin').buffers()
            end, desc = "Find existing buffers"
        },
        {
            mode = { 'n' }, '<leader>/', function()
                require('telescope.builtin')
                    .current_buffer_fuzzy_find(require('telescope.themes')
                        .get_dropdown({
                            winblend = 10,
                            previewer = false,
                        })
                    )
            end, desc = '[/] Fuzzily search in current buffer'
        },
        {
            desc = 'Search [G]it [F]iles',
            mode = { 'n' },
            '<leader>gf', function()
                require('telescope.builtin').git_files()
            end,
        },
        {
            desc = '[S]earch [F]iles',
            mode = { 'n' },
            '<leader>sf', function()
                require('telescope.builtin').find_files()
            end,
        },
        {
            desc = '[S]earch [H]elp',
            mode = { 'n' },
            '<leader>sh', function()
                require('telescope.builtin').help_tags()
            end,
        },
        {
            desc = '[S]earch Current [Word]',
            mode = { 'n' },
            '<leader>sw', function()
                require('telescope.builtin').grep_string()
            end,
        },
        {
            desc = '[S]earch by [G]rep',
            mode = { 'n' },
            '<leader>sg', function()
                require('telescope.builtin').live_grep()
            end,
        },
        {
            desc = '[S]earch [D]iagnostics',
            mode = { 'n' },
            '<leader>sd', function()
                require('telescope.builtin').diagnostics()
            end,
        },
    }
}

return M
