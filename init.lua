local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local config = require("telescope.config").values
local previewers = require "telescope.previewers"

local log = require("plenary.log"):new()
log.level = "debug"

local M = {}

local get_docker_logs = function(container)
  log.debug("Getting logs from container: " .. container)
  local cmd = vim.system { "docker", "logs", "-n", "10", container }
  local result = cmd:wait(100)

  if result.code == 0 then return result.stdout end

  return result.stderr
end

local sanitize_ports = function(ports)
  if ports == nil or ports == "" then return nil end

  local individual_ports = vim.split(ports, ", ")
  local sanitized_ports = {}

  for i = 1, #individual_ports do
    local splitted_port = vim.split(individual_ports[i], ":")
    table.insert(sanitized_ports, splitted_port[2])
  end

  return table.concat(sanitized_ports, ",")
end

M.make_running_containers_entry = function(entry)
  local parsed = vim.json.decode(entry)
  local ports = sanitize_ports(parsed.Ports)
  local value = parsed.Image

  if ports ~= nil then value = value .. " - " .. ports end

  return {
    value = parsed,
    display = value,
    ordinal = value,
  }
end

M.make_previewer_logs = function()
  return {
    title = "Logs",
    define_preview = function(self, entry)
      local logs = get_docker_logs(entry.value.Names)
      local lines = vim.split(logs, "\n")
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, lines)
    end,
  }
end

M.docker_logs = function(opts)
  pickers
    .new(opts, {
      finder = finders.new_async_job {
        command_generator = function() return { "docker", "ps", "--format", "json" } end,
        entry_maker = function(entry) return M.make_running_containers_entry(entry) end,
      },
      sorter = config.generic_sorter(opts),
      previewer = previewers.new_buffer_previewer(M.make_previewer_logs()),
    })
    :find()
end

return M
