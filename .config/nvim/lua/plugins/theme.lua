return function()
  vim.pack.add { 'https://github.com/sainnhe/gruvbox-material' }
  vim.g.gruvbox_material_background="medium"
  vim.g.gruvbox_material_forground="material"
  vim.cmd.colorscheme "gruvbox-material"
end
