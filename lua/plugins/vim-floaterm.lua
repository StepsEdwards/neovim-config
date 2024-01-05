return {
    'voldikss/vim-floaterm',
    version = '*',
    config = function()
        -- let g:floaterm_keymap_new    = '<F7>'
        -- let g:floaterm_titleposition    = '<F7>'
        -- vim.keymap.set('n', '\\\\', ':FloatermNew<CR>', { desc = 'New Terminal' })
        vim.cmd('hi FloatermBorder guibg= guifg=')
        -- vim.g.floaterm_wintype = 'vsplit'
        -- vim.g.floaterm_position = 'right'
        vim.g.floaterm_titleposition = 'center'
        vim.g.floaterm_width = 0.9
        vim.g.floaterm_height = 0.9
        -- vim.g.floaterm_autohide = 0
        vim.keymap.set('t', '<C-w>', '<C-\\><C-n>:FloatermNew<CR>', { desc = 'New Terminal' })
        vim.keymap.set('n', '\\\\', ':FloatermToggle<CR>', { desc = 'New Terminal' })
        vim.keymap.set('t', '\\\\', '<C-\\><C-n>:FloatermToggle<CR>', { desc = 'New Terminal' })
        vim.keymap.set('t', '<C-s>', '<C-\\><C-n>:FloatermKill<CR>:FloatermToggle<CR>',
            { desc = 'Kill Current Terminal' })
        vim.keymap.set('t', '<C-e>', '<C-\\><C-n>:FloatermNext<CR>', { desc = 'Next Terminal' })
        vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:FloatermPrev<CR>', { desc = 'Previous Terminal' })

        vim.keymap.set('n', '<leader>n', ':FloatermToggle --wintype="vsplit"<CR>', { desc = 'New Terminal (vertical)' })
        -- vim.keymap.set('t', '||', '<C-\\><C-n>:FloatermToggle<CR>', { desc = 'New Terminal' })
    end,
}
