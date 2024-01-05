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
  -- local handle = io.popen("curl -o /dev/null --silent --head --fail http://localhost:" .. port)
  local handle = io.popen("netstat -an | grep 5005")
  local exitCode = handle:close()
  local listCommand = os.execute("pwd")
  print(listCommand)
  print(handle)
  print(exitCode)

  if exitCode == 0 then
    return true
  else
    return false
  end
end

function spring_boot_run_debug()
  -- vim.cmd('term ./gradlew bootRun --debug-jvm')

  -- Command to start Spring Boot application with remote debugging
  -- local command = "./gradlew bootRun --debug-jvm"
  -- os.execute(command)
  vim.cmd('term ./gradlew bootRun --debug-jvm')

  -- Check if the remote debugging port is open
  local port = 5005 -- Assuming the default port is 5005
  -- while not isPortOpen(port) do
  --   print("sejj-sleeping")
  --   -- Wait for the port to be open
  --   os.execute("sleep 1")
  -- end

  -- Print a message once the remote debugging port is listening
  print("Remote debugging port is now listening!")

  -- Additional code...
end

print('Hello from')
isPortOpen(5005)
