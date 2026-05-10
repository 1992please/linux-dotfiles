-- Load and run all plugin files dynamically
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins/"
local plugin_files = vim.fn.readdir(plugin_dir)

for _, file in ipairs(plugin_files) do
  if file:match("%.lua$") then
    local name = file:gsub("%.lua$", "")
    local plugin = require("plugins." .. name)
    if type(plugin) == "function" then
      plugin()
    end
  end
end
