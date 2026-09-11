-- Neovim — starter config on top of the defaults.
-- Reference: https://neovim.io/doc/user/options.html
--
-- Options plus one plugin (the gruvbox colorscheme, via the built-in vim.pack),
-- no key mappings. Every key is stock Neovim, so :help and any tutorial apply.

local opt = vim.opt

-- Line numbers, relative so counts for j/k/dd are readable off the gutter
opt.number = true
opt.relativenumber = true

-- Two-space indents, expanded to spaces
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Case-insensitive search, unless the pattern contains a capital
opt.ignorecase = true
opt.smartcase = true

-- Share the system clipboard, so y and p cross the app boundary
opt.clipboard = "unnamedplus"

-- Persistent undo across sessions (~/.local/state/nvim/undo)
opt.undofile = true

opt.termguicolors = true
opt.signcolumn = "yes"  -- always shown, so text doesn't jump when a sign appears
opt.scrolloff = 8       -- keep context above/below the cursor
opt.splitright = true
opt.splitbelow = true
opt.mouse = "a"
opt.updatetime = 250

-- Gruvbox dark hard, matching Ghostty and tmux (installed via vim.pack on first start)
vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })
require("gruvbox").setup({ contrast = "hard", transparent_mode = true })
opt.background = "dark"
vim.cmd.colorscheme("gruvbox")

-- Briefly highlight yanked text, so it's obvious what was copied
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
