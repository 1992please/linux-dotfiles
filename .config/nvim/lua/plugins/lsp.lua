-- TODO: Don't forget about the auto complete features
return function()
  -- Install lsp config plugin
  vim.pack.add { 'https://github.com/neovim/nvim-lspconfig' }
  vim.lsp.enable('pyright')
  vim.lsp.enable("clangd")
  --=============================================================
  -- CMAKE
  --=============================================================
  --Enable (broadcasting) snippet capability for completion
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  vim.lsp.config('neocmake', {
    capabilities = capabilities,
  })
  vim.lsp.enable("neocmake")
  --=============================================================
  -- LUA
  --=============================================================
  vim.lsp.config('lua_ls', {
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
