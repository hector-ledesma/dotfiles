require("emi.packer")
require("emi.remap")
require("emi.set")
require("emi.linting")
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.md"},
    command = "set filetype=markdown",
})
vim.o.termguicolors = true
