return {
    'opdavies/toggle-checkbox.nvim',
    keys = {
        {
            "<leader>tt", mode = { "n" },
            ":lua require('toggle-checkbox').toggle()<CR>",
            desc = "Toggle Checkbox"
        },
    }
}
