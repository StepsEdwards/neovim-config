### Config Conventions
- set plugin version/branch/commit for each plugin in plugin manager (lazy.nvim) to prevent breaking changes when running Lazy commands
- find a way to have all keymaps located in one file that's easily searchable

### Datarouter
- [ ] start service
	- [ ] run maven goal for all dependencies and service (mvn clean install -DskipTests)
	- [ ] start tomcat server
	- [ ] deploy service WAR file to tomcat server
		- https://stackoverflow.com/questions/25029707/how-to-deploy-war-file-to-tomcat-using-command-prompt
	- [ ] easily view server logs (catalina.out, catalina.log, host-manager.log, localhost.log, manager.log)

### Zillow
- [ ] start service
	- [ ] easily view server logs
		- probably doesn't require much work since the spring boot logs can be found in the terminal where the server was spun up

### LSP Features
- [ ] code action
- [ ] completion
- [ ] declaration
- [ ] definition
- [ ] diagnostic
	- [ ] disable
	- [ ] enable
	- [ ] goto_next
	- [ ] goto_prev
	- [ ] open_float
	- [ ] setloclist
	- [ ] setqflist
- [ ] formatting
- [ ] hover
- [ ] implementation
- [ ] references
- [ ] rename
- [ ] signature help
- [ ] type definition

### Debugging
- [ ] Java (nvim-dap, nvim-dap-ui, telescope-dap)
	- [ ] Datarouter
		- [ ] start service in debug mode
		- [ ] attach debug adapter to service
	- [ ] Zillow
		- [ ] start service in debug mode
		- [ ] attach debug adapter to service
	- [ ] step over
	- [ ] step into
	- [ ] step out
	- [ ] step back *
	- [ ] toggle breakpoints
	- [ ] conditional breakpoints	
	- [ ] scopes
	- [ ] frames
	- [ ] expressions
	- [ ] threads
	- [ ] repl

### Testing
- [ ] run single test
- [ ] run single test in debug mode
- [ ] run test class
- [ ] run test class in debug mode

### Git
- [ ] lazygit
- [ ] vim-fugitive
- [ ] git worktrees

### Terminal
- [ ] vim-floaterm
- [ ] command prompt vim mode
- [ ] tmux OR zellij

### AI
- [ ] ChatGPT.nvim
- [ ] copilot.vim

### Formatting & Linting
null-ls.nvim

### Telescope
- [ ] save searches
- [ ] search specific file types
- [ ] search specific directory
- [ ] regex search

### File Explorer

### Snippets
- [ ] Java
- [ ] Javascript

### Other
- [ ] which-key.nvim
- [ ] dashboard
	- [ ] dashboard.nvim
	- [ ] vim.startify
- [ ] horizontal line number indicator/highlight
- [ ] sessions
- [ ] persistence.nvim
- [ ] noice.nvim
	- shortcuts [NORMAL MODE] - (q: OR q? OR q/)
	- [ ] nvim-notify
- [ ] wilder.nvim
- [ ] nvim-ts-autotag
- [ ] emmet (Mason)
- [ ] oil.nvim
- [ ] vim-dadbod / vim-dadbod.ui / vim-dadbod-completion
	- https://www.youtube.com/watch?v=NhTPVXP8n7w&t=24s
- [ ] bufferline.nvim
	- `:BufferLinePick` - jump between tabs
- [ ] indent-blankline
- [ ] smart-splits.nvim
	- rearrange splits
- [ ] nvim-spider
- [ ] zen-mode.nvim
- [x] toggle-checkbox.nvim

### Colorscheme & UI
- inspiration
	- https://www.youtube.com/watch?v=aeQn9MRTjxc
	- https://www.youtube.com/watch?v=uz1cTPju2xs&t=1s
- [ ] opaque terminal background
- [ ] nice desktop background that can be see behind the terminal
- [ ] terminal colorscheme matches neovim colorscheme
- [ ] remove/hide terminal header form minimal ui
