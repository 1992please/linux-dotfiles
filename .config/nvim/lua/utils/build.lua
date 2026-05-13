local M = {}

M.post_plugin_changed = function(plugin_name, cmd)
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      local cwd = ev.data.path
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == plugin_name then
        local result = vim.system(cmd, { cwd = cwd }):wait()
        -- if build failed
        if result.code ~= 0 then
          local stderr = result.stderr or ''
          local stdout = result.stdout or ''
          local output = stderr ~= '' and stderr or stdout
          if output == '' then output = 'No output from build command.' end
          vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
        else
          vim.notify(('Build success for %s'):format(name), vim.log.levels.TRACE)
        end

      end
    end
  })
end

return M
