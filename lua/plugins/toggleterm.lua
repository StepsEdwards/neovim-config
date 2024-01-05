local utils = require('utils')

return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require('toggleterm').setup({})
        local Terminal = require('toggleterm.terminal').Terminal
        local spring_boot_term = Terminal:new({
            display_name = 'spring_boot_term',
            dir = "~/ra-zgcp",
            direction = "float",
            auto_scroll = false,
        })
        local datarouter_term = Terminal:new({
            display_name = 'datarouter_term',
            direction = "float",
            auto_scroll = false,
        })


        function wait_for_terminal_prompt_to_load(terminal_buffer_number, terminal_prompt_pattern)
            -- wait 10 seconds or until terminal prompt has loaded, checking every ~500 ms
            vim.wait(10000, function()
                vim.cmd('redraw!')
                local terminal_lines = vim.api.nvim_buf_get_lines(terminal_buffer_number, 0, -1, false)
                utils.remove_empty_string_values_from_table(terminal_lines)
                if #terminal_lines > 0 then
                    local last_line = utils.trim_string(terminal_lines[#terminal_lines])
                    print('sejj-last-line:<<' .. last_line .. '>>')
                    return last_line == terminal_prompt_pattern
                end

                return false
            end, 500)
        end

        function execute_terminal_command(cmd, term, terminal_prompt_pattern)
            local term_buf_num = term.bufnr
            terminal_prompt_pattern = terminal_prompt_pattern or '$'
            wait_for_terminal_prompt_to_load(term_buf_num, terminal_prompt_pattern)
            term:send(cmd)
        end

        function attach_to_debug_process(port)
            local dap = require('dap')
            dap.configurations.java = {
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach to process',
                    hostName = 'localhost',
                    port = port,
                },
            }
            dap.continue()
        end

        vim.api.nvim_create_user_command('SpringBootStart', function()
            spring_boot_term:spawn()
            execute_terminal_command('dev_env_zgcp', spring_boot_term)
            execute_terminal_command('./gradlew bootRun', spring_boot_term)
            vim.cmd('echomsg "Spring Boot App Started."')
        end, {})

        vim.api.nvim_create_user_command('SpringBootDebugStart', function()
            spring_boot_term:spawn()
            execute_terminal_command('dev_env_zgcp', spring_boot_term)
            vim.cmd('echomsg "Starting app on port 9090 in debug mode."')
            execute_terminal_command('./gradlew bootRun --args="--server.port=9090" --debug-jvm', spring_boot_term)

            local status_code = nil
            vim.wait(10000, function()
                vim.cmd('redraw!')
                local handle = io.popen('lsof -i :5005 | grep LISTEN > /dev/null && echo $? 2>&1')
                if handle then
                    local output = handle:read("*a")
                    handle:close()

                    output = output:gsub('\n', '')
                    status_code = output
                end

                if tonumber(status_code) == 0 then
                    return true
                end

                return false
            end, 500)

            if tonumber(status_code) ~= 0 then
                vim.cmd('echomsg "Failed to start debugging!"')
                return
            end

            vim.cmd('echomsg "Attaching to debug process on port 5005..."')
            attach_to_debug_process('5005')
            vim.cmd('echomsg "Ready to debug."')
        end, {})

        vim.api.nvim_create_user_command('SpringBootStop', function()
            spring_boot_term:shutdown()
        end, {})

        vim.api.nvim_create_user_command('SpringBootTerminalToggle', function()
            spring_boot_term:toggle()
        end, {})

        vim.api.nvim_create_user_command('DatarouterStart', function()
        end, {})

        vim.api.nvim_create_user_command('DatarouterDebugStart', function(args)
            datarouter_term:toggle()
            if vim.trim(args.args) ~= 'skipDocker' then
                print('Executing docker script')
                execute_terminal_command('sudo /Users/stephensj/personal-dev-scripts/start-docker.sh', datarouter_term)
            end
            -- This script is run using `source` so that it executes in the 
            -- same shell environment as the terminal so the environment variable
            -- changes persist, otherwise the script is run in a subshell were the
            -- changes won't apply to the open terminal.
            execute_terminal_command('source /Users/stephensj/personal-dev-scripts/set-datarouter-environment-variables.sh', datarouter_term)
            execute_terminal_command('catalina jpda run', datarouter_term)
        end, { nargs = '*' })

        vim.api.nvim_create_user_command('DatarouterStop', function()
            datarouter_term:shutdown()
        end, {})

        vim.api.nvim_create_user_command('DatarouterTerminalToggle', function()
            datarouter_term:toggle()
        end, {})

        vim.api.nvim_create_user_command('MyInputScript', function(args)
            local terminals = require('toggleterm.terminal').get_all(true)
            for index, term in ipairs(terminals) do
                print('sejj-id-display_name: ' .. tostring(term.id) .. '-' .. term.display_name)
            end
        end, { nargs = '*' })

        -- vim.keymap.set('n', '<leader>Q', "<CMD> lua debug_spring_booty()<CR>")
        vim.keymap.set('n', '<leader>Q', ":SpringBootDebugStart<CR>")
        vim.keymap.set('n', '<leader>E', "<CMD> lua handle_test_term()<CR>")
        vim.keymap.set('n', '<leader>R', "<CMD> lua test_term_sleep()<CR>")
    end
}
