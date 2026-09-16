-- which-key.nvim: after a prefix key (<space>, g, z, <C-w>, ...) it pops up every key
-- that can follow and what it does, read from each mapping's desc. Loaded right after
-- startup, since it only matters once typing begins.
return {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {
    -- Names for the <space> prefixes, so the popup shows "find" and "git" instead of
    -- a bare "+2 keymaps"
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
    },
  },
}
