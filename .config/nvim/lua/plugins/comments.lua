return function()
  vim.pack.add {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/folke/todo-comments.nvim.git'
  }
  require('todo-comments').setup { signs = false }
end
