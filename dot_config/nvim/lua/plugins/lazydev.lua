-- lazydev.nvim: while editing Neovim config, points lua_ls at Neovim's runtime and the
-- installed plugins, so `vim` and `Snacks` are known globals and plugin APIs complete.
-- Only loads for Lua files.
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- vim.uv types, loaded only in files that mention vim.uv
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      -- snacks.nvim's types for the Snacks global, which is used without a require()
      { path = "snacks.nvim", words = { "Snacks" } },
    },
  },
}
