- Debug Spring Boot Application
    - 
### Debugging Spring Boot Service
1. start the spring boot service in debug mode to listen for remote debugging connections on the debug port (default: 5005)
```bash
./gradlew bootRun --debug-jvm
```
2. attach the neovim debug adapter (nvim-dap) to the spring boot application process for remote debugging
```
<leader>da
```
3. debug as usual (i.e. set break points/watch variables/etc. and make requests to application endpoints)

### Debugging Datarouter Service
#### Notes
- I took the `dev_env_datarouter` function from the scripts in `~/.zillow-bootstrap/files/rc.d/setup-ra` and moved it into its own
script in `~/personal-dev-scripts/dev-env-datarouter-wrapper` that could be run with `sudo` privileges and updated the `/etc/sudoers`
file to be able to run the new `dev-env-datarouter-wrapper` script without a password: 
`stephensj       ALL = (ALL:ALL) NOPASSWD: /Users/stephensj/personal-dev-scripts/dev-env-datarouter-wrapper`
so that I could execute that script before running the datarouter debug setup below. See the `DatarouterDebug` neovim command
defined, currently, in `toggleterm.lua` for the actual steps taken to start debugging.
- The `dev_env_datarouter` function cannot be setup be run with `sudo` becuase it is not a script/command, but rather a function that
is defined/registered when zillow-bootstrap is initialized/sourced at the beginning of each terminal session.

1. start tomcat in debug mode to listen for remote debugging connections on the debug port (default: 8080)
```bash
catalina.sh jpda run
```
2. deploy the service WAR file to the tomcat server.
3. attach the neovim debug adapter (nvim-dap) to the tomcat server's remote debugging port from step 1.
```
<leader>dA
```
4. debug as usual (i.e. set break points/watch variables/etc. and make requests to application endpoints)
