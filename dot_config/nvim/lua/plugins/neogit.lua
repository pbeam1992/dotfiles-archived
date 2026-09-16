-- Neogit, a magit-style git UI (:Neogit), plus diffview.nvim for its diff popup and
-- side-by-side diffs. Neogit follows its greatest semver tag (v3 today, later majors
-- as they ship); diffview has no tags, so it tracks its default branch. Loaded on
-- first use of :Neogit or <space>gg. lazygit stays as the CLI tool outside nvim.
return {
  "NeogitOrg/neogit",
  version = "*",
  dependencies = {
    -- Required by the released neogit (v3.0.0); master has already dropped it, so
    -- remove this line once a release without it is out.
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  cmd = "Neogit",
  -- <space>gg opens the status buffer, the one entry point to everything else
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit status" },
  },
  -- Defaults everywhere (status opens in its own tab); only the diffview integration is
  -- switched on, so d in the status buffer opens diffs in diffview.
  opts = {
    integrations = { diffview = true },
  },
}
