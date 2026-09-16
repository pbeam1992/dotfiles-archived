-- Neogit, a magit-style git UI (:Neogit), plus diffview.nvim for its diff popup and
-- side-by-side diffs. Neogit follows its greatest semver tag (v3 today, later majors
-- as they ship); diffview has no tags, so it tracks its default branch. Both are
-- installed via vim.pack on first start. lazygit stays as the CLI tool outside nvim.
--
-- plenary.nvim is required by the released neogit (v3.0.0); master has already
-- dropped it, so remove the plenary line once a release without it is out.
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  { src = "https://github.com/NeogitOrg/neogit", version = vim.version.range("*") },
  "https://github.com/sindrets/diffview.nvim",
})

-- Defaults everywhere (status opens in its own tab); only the diffview integration is
-- switched on, so d in the status buffer opens diffs in diffview.
require("neogit").setup({
  integrations = { diffview = true },
})

-- <space>gg opens the status buffer, the one entry point to everything else
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit status" })
