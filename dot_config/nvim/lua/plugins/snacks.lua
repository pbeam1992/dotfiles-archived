-- snacks.nvim, a collection of small modules. Only the picker is enabled, so each
-- module can be learned on its own: to try another one later, add
-- `<name> = { enabled = true }` to opts. Snacks asks to be loaded at startup with high
-- priority; modules left disabled are never set up, so that costs nothing.
-- The files picker uses fd and grep uses ripgrep, both from the Brewfile.
-- :lua Snacks.picker() lists every picker source, to find more before mapping them.
return {
  "folke/snacks.nvim",
  version = "*",
  lazy = false,
  priority = 1000,
  opts = {
    picker = { enabled = true },
  },
  -- <space>f ("find") prefix for the handful of pickers used daily
  keys = {
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help pages" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc = "Resume last picker" },
  },
}
