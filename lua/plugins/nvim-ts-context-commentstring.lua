return {
    'JoosepAlviste/nvim-ts-context-commentstring',
    -- config = function ()
    --     require('ts_context_commentstring').setup()
    -- end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'numToStr/Comment.nvim',
    },
    lazy = false,
}
