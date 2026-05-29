-- TODO: Don't forget about the auto complete features
return function()
  -- Servers to install
  -- pyright clangd glsl_analyzer neocmake lua-language-server
  -- codelldb
  vim.pack.add { 'https://github.com/mason-org/mason.nvim' }
  require("mason").setup()

  vim.pack.add { 'https://github.com/neovim/nvim-lspconfig' }

  --Enable (broadcasting) snippet capability for completion
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

  -- python
  vim.lsp.config('pyright', {
    capabilities = capabilities,
  })
  vim.lsp.enable('pyright')

  -- c++
  vim.lsp.config('clangd', {
    cmd = {
      'clangd',
      '--header-insertion=never',
    },
    capabilities = capabilities,
  })
  vim.lsp.enable('clangd')
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf
      -- Get the client that just attached
      local client = vim.lsp.get_client_by_id(event.data.client_id)

      -- Check if this is clangd
      if client and client.name == 'clangd' then
        -- This mapping only exists for clangd buffers
        vim.keymap.set('n', '<leader>h', ':LspClangdSwitchSourceHeader<CR>',
          { buffer = buf, desc = 'Switch header/source (clangd)' })

        -- Optional: Also add the symbol info shortcut
        vim.keymap.set('n', '<leader>si', ':LspClangdShowSymbolInfo<CR>',
          { buffer = buf, desc = 'Show symbol info (clangd)' })
      else
      end
    end,
  })

  -- glsl
  vim.lsp.config('glsl_analyzer', {
    capabilities = capabilities,
  })
  vim.lsp.enable('glsl_analyzer')

  -- cmake
  vim.lsp.config('neocmake', {
    capabilities = capabilities,
  })
  vim.lsp.enable("neocmake")

  -- lua
  vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
  })
  vim.lsp.enable('lua_ls')

end
