local utils = require('utils')

local has_attached_debugger = false

return {
    'akinsho/toggleterm.nvim', version = "*",
    config = function()
        require('toggleterm').setup({})
        local Terminal = require('toggleterm.terminal').Terminal
        local spring_boot_term = Terminal:new({
            display_name = 'spring_boot_term',
            dir = "~/ra-zgcp",
            direction = "float",
            auto_scroll = false,
            on_stdout = function (t, job, data, name)
                local terminal_lines = vim.api.nvim_buf_get_lines(t.bufnr, -10, -1, false)
                terminal_lines = vim.tbl_filter(function(line)
                    return line ~= ''
                end, terminal_lines)
                local ready_to_attach_debugger = vim.tbl_contains(terminal_lines, "Listening for transport dt_socket at address: 5005")
                if ready_to_attach_debugger and not has_attached_debugger then
                    print('Attaching debugger...')
                    attach_to_debug_process('5005')
                    has_attached_debugger = true
                end
            end
        })
        local datarouter_term = Terminal:new({
            display_name = 'datarouter_term',
            direction = "float",
            auto_scroll = false,
            on_stdout = function (t, job, data, name)
                local terminal_lines = vim.api.nvim_buf_get_lines(t.bufnr, 0, -1, false)
                terminal_lines = vim.tbl_filter(function(line)
                    return line ~= ''
                end, terminal_lines)

                -- local exit_code = get_command_exit_code('lsof -i :8000 | grep LISTEN')
                -- if exit_code == 0 then
                --     print('Attaching to JPDA debug process')
                --     attach_to_debug_process('8000')
                -- end
            end
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

        function wait_for_term_to_load(term_bufnr, term_prompt_pattern)
            term_prompt_pattern = term_prompt_pattern or '$'
            vim.schedule(function ()
                -- local lines = vim.api.nvim_buf_get_lines(term_bufnr, first_line, last_line, false)
                local terminal_lines = vim.api.nvim_buf_get_lines(term_bufnr, 0, -1, false)
                if terminal_lines[2] == nil or utils.trim_string(terminal_lines[2]) ~= '$' then
                    vim.schedule(function ()
                        -- print('SEJJ-SCHEDULING_DUE_TO_NIL')
                        -- print('sejj-line_1: ' .. tostring(terminal_lines[1]))
                        -- print('sejj-line_2: ' .. tostring(terminal_lines[2]))
                        print(vim.inspect(terminal_lines))
                        wait_for_term_to_load(term_bufnr, term_prompt_pattern)
                    end)
                    return
                end
                -- if utils.trim_string(terminal_lines[1]) == '$' then
                    print('SEJJ-PROMPT_LOADED!!!!')
                -- end
            end)
            -- vim.api.nvim_buf_attach(term_bufnr, false, {
            --     on_lines = function (_, _, _, first_line, last_line)
            --         local lines = vim.api.nvim_buf_get_lines(term_bufnr, first_line, last_line, false)
            --         print(vim.inspect(lines))
            --     end
            -- })
        end

        function execute_terminal_command(cmd, term, terminal_prompt_pattern)
            local term_buf_num = term.bufnr
            terminal_prompt_pattern = terminal_prompt_pattern or '$'
            wait_for_terminal_prompt_to_load(term_buf_num, terminal_prompt_pattern)
            term:send(cmd)
        end

        function exec_term_cmd(cmd, term, terminal_prompt_pattern)
            DETACH = false
            local bufnr = term.bufnr
            terminal_prompt_pattern = terminal_prompt_pattern or '$'
            term:toggle()
            local current_mode = vim.api.nvim_get_mode().mode
            -- print('sejj-start_mode:' .. current_mode)
            vim.cmd(':startinsert')
            current_mode = vim.api.nvim_get_mode().mode
            -- print('sejj-end_mode:' .. current_mode)



            vim.api.nvim_buf_attach(bufnr, false, {
                on_lines = function(_, _, _, first_line, last_line)
                    -- if DETACH then
                    --     return true
                    -- end
                    
                    local lines = vim.api.nvim_buf_get_lines(bufnr, first_line, last_line, false)
                    print(vim.inspect(lines))
                    -- print('sejj-lines[1]: ' .. tostring(lines[1]))
                    if lines[1] == nil then
                        print('sejj-NIL_LINE!!!!!!!')
                        return true
                    end

                    if utils.trim_string(lines[1]) == terminal_prompt_pattern then
                        vim.schedule(function ()
                            term:send(cmd)
                        end)
                    end
                    -- print(vim.inspect(lines))
                        -- print(vim.inspect(lines))
                        -- print(vim.inspect(utils.trim_string(lines[1])))
                        -- if lines[1] ~= nil then
                        -- end
                        -- vim.api.nvim_buf_set_lines(datarouter_term.bufnr, 0, -1, false, lines)
                end,
                on_detach = function ()
                    print(vim.inspect('detatching from terminal buffer'))
                end
            })
        end

        function exec_cmd(cmd, term, term_prompt_pattern)
            term_prompt_pattern = term_prompt_pattern or '$'

            local bufnr = term.bufnr
            local terminal_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            print(vim.inspect(terminal_lines))
            utils.remove_empty_string_values_from_table(terminal_lines)

            if #terminal_lines > 0 then
                if utils.trim_string(terminal_lines[#terminal_lines]) == term_prompt_pattern then
                    print('Sending term command!')
                    term:send(cmd)
                    return terminal_lines
                end
            end

            vim.schedule(function ()
                exec_cmd(cmd, term, term_prompt_pattern)
            end)
        end

        function term_prompt_loaded(cmd, term, term_prompt_pattern, has_loaded_once)
            term_prompt_pattern = term_prompt_pattern or '$'
            has_loaded_once = has_loaded_once or false

            local bufnr = term.bufnr
            local terminal_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local has_prompt_loaded_count = 0
            utils.remove_empty_string_values_from_table(terminal_lines)

            -- stephensj:~/.local/state/nvim/swap

            if #terminal_lines > 0 then
                if has_loaded_once then
                    print('1-have_already_sent_cmd')
                end
                local last_line = utils.trim_string(tostring(terminal_lines[#terminal_lines])) -- Ex. '$'
                local second_to_last_line = utils.trim_string(tostring(terminal_lines[#terminal_lines - 1])) -- Ex. 'stephensj:~/workspace/rpjava (rpjava) (master)'
                -- print('last_line: ' .. last_line)
                -- print('second_to_last_line: ' .. second_to_last_line)
                local tempArr = {}
                -- split terminal line using spaces
                for word in string.gmatch(second_to_last_line, "%S+") do
                    table.insert(tempArr, word)
                end
                local expected_prompt_user_dir = tempArr[1]
                -- print('expected_prompt_user_dir', vim.inspect(expected_prompt_user_dir))

                local term_dir_after_colon = string.match(utils.trim_string(tostring(expected_prompt_user_dir)), ":(.+)")
                -- print('term_dir_after_colon: ' .. tostring(term_dir_after_colon))
                local expanded_term_dir_after_colon = vim.fn.expand(term_dir_after_colon)
                -- print('expanded_term_dir_after_colon: ' .. expanded_term_dir_after_colon)
                local expanded_term_user_and_dir = string.gsub(second_to_last_line, ":.*", ":" .. expanded_term_dir_after_colon)
                -- print('expanded_term_user_and_dir: ' .. expanded_term_user_and_dir)

                -- print(last_line .. '==' .. term_prompt_pattern)
                -- print(expanded_term_user_and_dir .. '==' .. string.format('stephensj:%s', vim.fn.expand(term.dir)))
                local has_prompt_loaded = last_line == term_prompt_pattern and expanded_term_user_and_dir == string.format('stephensj:%s', vim.fn.expand(term.dir))
                -- local has_prompt_loaded = last_line == term_prompt_pattern and expanded_term_user_and_dir == string.format('stephensj:%s', vim.fn.expand(vim.fn.getcwd()))
                -- print('has_prompt_loaded: ' .. tostring(has_prompt_loaded))
                -- return
                if has_prompt_loaded then
                    -- print('has_loaded_once', tostring(has_loaded_once))
                    -- if has_loaded_once then
                    --     print('returning_terminal_lines')
                    --     return terminal_lines
                    -- end

                    if not has_loaded_once then
                        print('Sending term command!')
                        term:send(cmd)
                        print('Scheduling with has_loaded_once == true')
                        vim.schedule(function()
                            print('========== Executing Scheduled Function (START) ==========')
                            term_prompt_loaded(cmd, term, term_prompt_pattern, true)
                            print('========== Executing Scheduled Function (END) ==========')
                        end)
                        return
                    end

                    print('printing_terminal_lines', vim.inspect(terminal_lines))
                    return terminal_lines
                end
            end

            -- print('No terminal lines to output')
            if not has_loaded_once then
                vim.schedule(function ()
                    -- print('Scheduling with has_loaded_once == false')
                    term_prompt_loaded(cmd, term, term_prompt_pattern)
                end)
            end

            -- vim.schedule(function ()
            --     exec_cmd(cmd, term, term_prompt_pattern)
            -- end)
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
            print('Debugger attached.')
        end

        local DEBUG_COUNT = 0
        function debug_attach(port)
            local tomcat_is_running = get_command_exit_code('lsof -i :8443 | grep LISTEN') == 0
            local waiting_to_debug = get_command_exit_code('lsof -i :8000 | grep LISTEN') == 0
            local already_attached = get_command_exit_code('lsof -i :8000 | grep ESTABLISHED') == 0

            if not port then
                print('ERROR: no debug port provided!')
            end

            if tomcat_is_running and waiting_to_debug and not already_attached then
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
                print('Debugger attached.')
                return
            end

            vim.schedule(function ()
                print(tostring(DEBUG_COUNT) .. ': Attempting to attach to debugger...')
                DEBUG_COUNT = DEBUG_COUNT + 1
                debug_attach(port)
            end)
        end

        function start_debugging(debug_port)
            debug_port = debug_port or '5005'
            local status_code = nil
            -- local handle = io.popen('lsof -i :5005 | grep LISTEN > /dev/null && echo $? 2>&1')
            -- local handle = io.popen('lsof -i :8000 | grep LISTEN > /dev/null && echo $? 2>&1')
            local handle = io.popen(string.format('lsof -i :%s | grep LISTEN > /dev/null && echo $? 2>&1', debug_port))
            if handle then
                local output = handle:read("*a")
                handle:close()

                output = output:gsub('\n', '')
                status_code = output
            end

            if tonumber(status_code) == 0 then
                -- vim.cmd('echomsg "Attaching to debug process on port 5005..."')
                -- vim.cmd('echomsg string.format("Attaching to debug process on port %s", debug_port)')
                print(string.format("Attaching to debug process on port %s", debug_port))
                attach_to_debug_process(debug_port)
                return
            end

            vim.schedule(function()
                start_debugging()
            end)
        end

        function get_command_exit_code(cmd)
            local exit_code = nil
            local program = string.format('%s \necho _$?', cmd)

            local file = io.popen(program)
            if file then
                exit_code = file:read('*a'):match('.*%D(%d+)') + 0
                file:close()
            end

            return exit_code
        end

        function get_process_id(port)
            local process_id = nil
            local cmd =  string.format('lsof -i :%s | grep LISTEN | awk \'{print $2}\'', port)
            local file = io.popen(cmd)
            if file then
                local output = file:read("*a")
                file:close()

                process_id = output:gsub('\n', '')
            end
            
            print(vim.inspect(process_id))
            return process_id
        end
        
        function user_command_args_to_table(args)
            local tbl_args = {}
            for _, arg in ipairs(args.fargs) do
                local key = vim.split(arg, '=')[1]
                local value = vim.split(arg, '=')[2]
                tbl_args[key] = value
            end

            return tbl_args
        end

        function toboolean(value)
            if value == "true" then
                return true
            end
            return false
        end

        vim.api.nvim_create_user_command('SpringBootStart', function()
            spring_boot_term:spawn()
            spring_boot_term:send('dev_env_zgcp')
            spring_boot_term:send('./gradlew bootRun')
            print("Spring Boot App Started.")
        end, {})

        vim.api.nvim_create_user_command('SpringBootDebug', function()
            spring_boot_term:spawn()
            spring_boot_term:send('dev_env_zgcp')
            print("Starting app on port 9090 in debug mode.")
            spring_boot_term:send('./gradlew bootRun --args="--server.port=9090" --debug-jvm')
        end, {})

        vim.api.nvim_create_user_command('SpringBootStop', function()
            spring_boot_term:shutdown()
        end, {})

        vim.api.nvim_create_user_command('SpringBootTerminalToggle', function()
            spring_boot_term:toggle()
            vim.cmd(':startinsert')
            wait_for_term_to_load(spring_boot_term.bufnr)
        end, {})

        vim.api.nvim_create_user_command('DatarouterStart', function(args)
            datarouter_term:toggle()
            if vim.trim(args.args) ~= 'skipDocker' then -- Ex. DatarouterStart skipDocker
                print('Executing docker script')
                datarouter_term:send('sudo /Users/stephensj/personal-dev-scripts/start-docker.sh')
            end

            -- This script is run using `source` so that it executes in the 
            -- same shell environment as the terminal so the environment variable
            -- changes persist, otherwise the script is run in a subshell were the
            -- changes won't apply to the open terminal.
            datarouter_term:send('source /Users/stephensj/personal-dev-scripts/set-datarouter-environment-variables.sh')
        end, { nargs = '*' })

        vim.api.nvim_create_user_command('DatarouterDebugStart', function(args)
            local tbl_args = user_command_args_to_table(args)
            local app_name = tbl_args.app_name
            local debug = toboolean(tbl_args.debug)

            if not app_name then
                print('ERROR: no app_name supplied.')
                return
            end

            datarouter_term:spawn()

            datarouter_term:send('start_time=$(date +%s)')
            
            local docker_is_running = get_command_exit_code('docker info') == 0
            print('docker_is_running: ' .. vim.inspect(docker_is_running))
            if not docker_is_running then
                datarouter_term:send('sudo /Users/stephensj/personal-dev-scripts/start-docker.sh')
            end

            datarouter_term:send('source /Users/stephensj/personal-dev-scripts/set-datarouter-environment-variables.sh')

            local tomcat_is_running = get_command_exit_code('lsof -i :8443 | grep LISTEN') == 0
            if not tomcat_is_running then
                datarouter_term:send('catalina jpda start')
                datarouter_term:send('sleep 5')
                debug_attach('8000')
            end

            local app_is_deployed = get_command_exit_code(string.format('curl --user sejj:sejj --insecure "https://localhost:8443/manager/text/list" | grep %s', app_name) == 0)
            if app_is_deployed then
                datarouter_term:send(string.format('curl --user sejj:sejj --insecure "https://localhost:8443/manager/text/undeploy?path=/%s"', app_name))
            end

            datarouter_term:send(string.format('curl --user sejj:sejj --insecure --upload-file /Users/stephensj/workspace/rpjava/app/%s/server/target/%s.war "https://localhost:8443/manager/text/deploy?path=/%s"', app_name, app_name, app_name))
            'curl --user sejj:sejj --insecure --upload-file /Users/stephensj/workspace/rpjava/app/capps/server/target/capps.war "https://localhost:8443/manager/text/deploy?path=/capps"'

            print('Finished!!!')
            
            datarouter_term:send('echo $(( $(date +%s) - $start_time))')
        end, {
            nargs = '*',
            complete = function(_, _, _)
                return {
                    'app_name=capps',
                    'app_name=screening',
                    'app_name=id-verification',
                    'app_name=application-payment',
                    'app_name=seattle-rental-inlet',
                    'app_name=renter-hub-api',
                    'app_name=rental-manager-api',
                }
            end
        })

        vim.api.nvim_create_user_command('DatarouterStartScript', function()
            datarouter_term:toggle()

            -- This script is run using `source` so that it executes in the 
            -- same shell environment as the terminal so the environment variable
            -- changes persist, otherwise the script is run in a subshell were the
            -- changes won't apply to the open terminal.
            datarouter_term:send('source /Users/stephensj/personal-dev-scripts/datarouter-debug-start.sh')
        end, {})
        
        vim.api.nvim_create_user_command('DatarouterStartDebugScript', function()
            datarouter_term:toggle()
            datarouter_term:send('source /Users/stephensj/personal-dev-scripts/datarouter-debug-start.sh "" "" true')
        end, {})

        vim.api.nvim_create_user_command('DatarouterStop', function()
            datarouter_term:shutdown()
        end, {})

        vim.api.nvim_create_user_command('DatarouterTerminalToggle', function()
            datarouter_term:toggle()
        end, {})

        -- vim.keymap.set('n', '<leader>Q', "<CMD> lua debug_spring_booty()<CR>")
        vim.keymap.set('n', '<leader>Q', ":SpringBootDebugStart<CR>")
        vim.keymap.set('n', '<leader>E', "<CMD> lua handle_test_term()<CR>")
        vim.keymap.set('n', '<leader>R', "<CMD> lua test_term_sleep()<CR>")
    end
}
