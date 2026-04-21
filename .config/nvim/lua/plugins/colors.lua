return {
    {
	"sainnhe/gruvbox-material",
	lazy = false,
	config = function()
	    vim.g.gruvbox_material_background="hard"
	    vim.g.gruvbox_material_forground="material"
            vim.cmd.colorscheme "gruvbox-material"
	end
    }
}
