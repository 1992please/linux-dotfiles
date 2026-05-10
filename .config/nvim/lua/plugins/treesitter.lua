return function()
  vim.pack.add {
    { src = "https://github.com/romus204/tree-sitter-manager.nvim" }
  }

  require("tree-sitter-manager").setup({
    -- Default Options
    ensure_installed = { 'bash', 'c', 'cpp', 'glsl', 'hlsl', 'cmake', 'diff', 'html', 'lua', 'luadoc',
      'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
    border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
    auto_install = true, -- if enabled, install missing parsers when editing a new file
    highlight = true, -- treesitter highlighting is enabled by default
    nohighlight = {},
  })
  -- Enable treesitter based folds
  -- For more info on folds see `:help folds`
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'
end
