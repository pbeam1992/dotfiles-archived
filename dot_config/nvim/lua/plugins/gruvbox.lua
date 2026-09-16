-- Gruvbox dark hard, matching Ghostty and tmux (installed via vim.pack on first start)
vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })
require("gruvbox").setup({ contrast = "hard", transparent_mode = true })
vim.opt.background = "dark"
vim.cmd.colorscheme("gruvbox")
