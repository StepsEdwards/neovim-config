-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Navigate to left split' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Navigate to bottom split' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Navigate to top split' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Navigate to right split' })
-- vim.keymap.set('n', '<TAB>', '>>^', { desc = 'Indent Line' })
-- vim.keymap.set('n', '<S-TAB>', '<<^', { desc = 'Unindent Line' })
-- vim.keymap.set('i', '<TAB>', '<C-o>>><C-o>$', { desc = 'Indent Line' })
-- vim.keymap.set('i', '<S-TAB>', '<C-o><<<C-o>$', { desc = 'Unindent Line' })
-- vim.keymap.set('v', '<TAB>', '>><Esc>', { desc = 'Indent Line' })
-- vim.keymap.set('v', '<S-TAB>', '<<<Esc>', { desc = 'Unindent Line' })

-- Remap for dealing with word wrap. This allows you to not skip a wrapped line when
-- when pressing j,k. Allows for a more natural and expected vertical movement.
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- ------------------
-- vim.api.nvim_set_keymap('t', '<C-l><C-l>', [[<C-\><C-N>:lua ClearTerm(0)<CR>]], mapping_opts)
-- vim.api.nvim_set_keymap('t', '<C-l><C-l><C-l>', [[<C-\><C-N>:lua ClearTerm(1)<CR>]], mapping_opts)

function ClearTerm(reset)
  vim.opt_local.scrollback = 1

  vim.api.nvim_command("startinsert")
  if reset == 1 then
    vim.api.nvim_feedkeys("reset", 't', false)
  else
    vim.api.nvim_feedkeys("clear", 't', false)
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<cr>', true, false, true), 't', true)

  vim.opt_local.scrollback = 10000
end

vim.keymap.set('t', '<C-l><C-l>', [[<C-\><C-N>:lua ClearTerm(0)<CR>]])
vim.keymap.set('t', '<C-l><C-l><C-l>', [[<C-\><C-N>:lua ClearTerm(1)<CR>]])
-- ------------------

function get_spring_boot_runner()

end

function attach_to_debug_process()
  local dap = require('dap')
  dap.configurations.java = {
    {
      type = 'java',
      request = 'attach',
      name = 'Attach to process',
      hostName = 'localhost',
      port = '5005',
    },
  }
  dap.continue()
end

function attach_to_debug_tomcat()
  local dap = require('dap')
  dap.configurations.java = {
    {
      type = 'java',
      request = 'attach',
      name = 'Attach to process',
      hostName = 'localhost',
      port = '8000',
    },
  }
  dap.continue()
end

function spring_boot_run()
  vim.cmd('term ./gradlew bootRun')
end

-- Function to check if a port is open
function isPortOpen(port)
  -- local socket = require("socket")
  -- local host = "127.0.0.1"
  -- local connection = socket.tcp()
  --
  -- connection:settimeout(1) -- Set the timeout to 1 second
  -- local result = connection:connect(host, port)
  --
  -- connection:close() -- Close the connection
  --
  -- if result ~= nil then
  --   return true
  -- else
  --   return false
  -- end
  local handle = io.popen("curl -o /dev/null --silent --head --fail http://localhost:" .. port)
  local exitCode = handle:close()
  -- print("sejj-exitCode: " .. exitCode)

  if exitCode == 0 then
    return true
  else
    return false
  end
end

function spring_boot_run_debug()
  -- vim.cmd('term ./gradlew bootRun --debug-jvm')

  -- Command to start Spring Boot application with remote debugging
  -- local command = "./gradlew bootRun --debug-jvm &"
  -- os.execute(command)
  -- vim.cmd('term ./gradlew bootRun --debug-jvm &')
  -- local job_id = vim.fn.jobstart('term ./gradlew bootRun --debug-jvm &', {
  --   on_exit = function(job_id, _, _)
  --     print('Command executed successfully,,,')
  --     -- Handle any further logic here
  --   end,
  --   detach = true,
  -- })

  local timeout = 3000 -- Timeout in milliseconds
  local start_time = vim.loop.now()

  vim.wait(function()
    -- Check if the condition is met
    return vim.loop.now() - start_time >= timeout
  end, timeout)

  -- Executed after the condition is met or the timeout occurs
  -- print("Next command executed")
  -- print('sejj-job_id: ' .. job_id)
  -- os.execute("sleep 15")
  -- local status_code = 1

  -- attach_to_debug()

  -- Check if the remote debugging port is open
  -- local port = 5005 -- Assuming the default port is 5005
  -- while status_code ~= 0 do
  --   print('sejj-status_code: ' .. status_code)
  --   status_code = os.execute('lsof -i :5005 | grep LISTEN')
  --   --   print("sejj-sleeping")
  --   --   -- Wait for the port to be open
  --   --   os.execute("sleep 1")
  -- end

  -- Print a message once the remote debugging port is listening
  print("Remote debugging port is now listening!")

  -- Additional code...
end

function debug_testing()
  local cmd = os.execute('lsof -i :5005 | grep LISTEN')
  print('sejj-cmd-start')
  print(cmd)
  print('sejj-cmd-end')
end

vim.keymap.set('n', '<leader>AA', ':lua spring_boot_run_debug()<CR>')
vim.keymap.set('n', '<leader>j', ':lua debug_testing()<CR>')

vim.keymap.set('n', '<leader>da', ':lua attach_to_debug()<CR>')
vim.keymap.set('n', '<leader>dA', ':lua attach_to_debug_tomcat()<CR>')

vim.keymap.set('n', '<leader>cd', ':lua require("dap").continue()<CR>')
-- vim.keymap.set('n', '<leader>j', ':lua require"dap".step_over()<CR>')
vim.keymap.set('n', '<leader>l', ':lua require"dap".step_into()<CR>')
vim.keymap.set('n', '<leader>h', ':lua require"dap".step_out()<CR>')

vim.keymap.set('n', '<leader>b', ':lua require"dap".toggle_breakpoint()<CR>')
vim.keymap.set('n', '<leader>B', ':lua require"dap".set_breakpoint(vim.fn.input("Condition: "))<CR>')
vim.keymap.set('n', '<leader>Bl', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log: "))<CR>')
vim.keymap.set('n', '<leader>dr', ':lua require"dap".repl.open()<CR>')
