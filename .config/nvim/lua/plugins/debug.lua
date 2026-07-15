return function()
  vim.pack.add {
    'https://github.com/mfussenegger/nvim-dap',
    { src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*")  },
  }

  local dap = require('dap')
  dap.adapters.codelldb = {
    type = "executable",
    command = "codelldb",
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp

  vim.keymap.set('n', '<F9>', function() dap.continue() end, { desc = "Start/Continue Debugging" })
  vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "Step Over" })
  vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "Step Into" })
  vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = "Step Out" })
  vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
  vim.keymap.set('n', '<Leader>de', function() dap.terminate() end, { desc = "Stop Debugging" })

  local view = require('dap-view')

  -- Open the view when a debug session is attached or launched
  dap.listeners.before.attach['dap-view-config'] = function()
    view.open()
  end
  dap.listeners.before.launch['dap-view-config'] = function()
    view.open()
  end

  -- Close the view when the debug session terminates or the debugee exits
  dap.listeners.before.event_terminated['dap-view-config'] = function()
    view.close()
  end
  dap.listeners.before.event_exited['dap-view-config'] = function()
    view.close()
  end
end
