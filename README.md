# Telescope Docker logs
## WIP

Inspired by krisajenkins' [telescope-docker.nvim](https://github.com/krisajenkins/telescope-docker.nvim)

Just trying to learn more about nvim.

The idea is to check logs from running containers using [telescope](https://github.com/nvim-telescope/telescope.nvim)

Inside ~/.config/nvim/init.lua:
```lua
local docker = require "plugins.telescope_docker"
vim.keymap.set("n", "<leader>fD", docker.docker_logs, {})
```

You should get something like this:
![alt text](https://i.postimg.cc/4yTJ9GWv/Screenshot-from-2025-03-07-10-07-03.png)
