-- Neovim - starter config on top of the defaults.
-- Reference: https://neovim.io/doc/user/options.html
--
-- Options and autocmds live here. Plugins are managed by lazy.nvim, which clones itself
-- on first start. Each plugin is one self-contained lazy spec file under lua/plugins/
-- (source, setup options and key mappings), picked up automatically by the import
-- below, so adding a plugin = one new file there. The only mappings are the plugin
-- ones, under <space> as leader; everything else is stock Neovim, so :help and any
-- tutorial apply.

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

-- <space> as leader. Must be set before any mapping that uses it, so before lazy.nvim.
vim.g.mapleader = " "

-- Bootstrap lazy.nvim (~/.local/share/nvim/lazy/lazy.nvim) if it is not installed yet
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Every file in lua/plugins/ returns a spec
  spec = { { import = "plugins" } },
  -- Colorscheme for the install UI on first start
  install = { colorscheme = { "gruvbox" } },
  -- Updates are deliberate (:Lazy update, then chezmoi re-add the lockfile)
  checker = { enabled = false },
  -- No plugin needs luarocks; off so :checkhealth lazy does not ask for it
  rocks = { enabled = false },
})
