-- Gruvbox dark hard, matching Ghostty and tmux. Loaded at startup, ahead of every other
-- plugin, so the colorscheme is in place before anything draws.
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  opts = { contrast = "hard", transparent_mode = true },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.opt.background = "dark"
    vim.cmd.colorscheme("gruvbox")
  end,
}
