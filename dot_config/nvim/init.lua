-- Neovim - starter config on top of the defaults.
-- Reference: https://neovim.io/doc/user/options.html
--
-- Options and autocmds live here. Each plugin is one self-contained file under
-- lua/plugins/ (its own vim.pack.add, setup and key mappings), required at the
-- end of this file, so adding a plugin = one new file there + one require line.
-- The only mappings are the plugin ones, under <space> as leader; everything
-- else is stock Neovim, so :help and any tutorial apply.

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

-- Briefly highlight yanked text, so it's obvious what was copied
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- <space> as leader. Must be set before any mapping that uses it, so before the plugins.
vim.g.mapleader = " "

-- Plugins, one file each. Gruvbox first, so the colorscheme is in place before anything draws.
require("plugins.gruvbox")
require("plugins.neogit")
