-- Clear highlights on search when pressing <Esc> <C-c> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-c>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format() end, { desc = "Format document" })
vim.keymap.set('n', 'grd', function() vim.lsp.buf.definition() end, { desc = '[G]oto [D]efinition' })
