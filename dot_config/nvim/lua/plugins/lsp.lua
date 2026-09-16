-- Language servers. Three plugins, one job each:
--   mason.nvim           installs servers into ~/.local/share/nvim/mason/ (:Mason to browse)
--   nvim-lspconfig       ships each server's config (cmd, filetypes, root markers); no setup()
--   mason-lspconfig.nvim installs ensure_installed and passes every Mason-installed server
--                        to Neovim's built-in vim.lsp.enable(), which starts and attaches it
-- ensure_installed is the list both Macs converge on: a server tried out with `i` in
-- :Mason works right away, but only lands on the other Mac once it is added here.
-- Mason has no lockfile, so server versions are not pinned. The npm-based servers run on
-- mise's Node. A per-server override goes in after/lsp/<name>.lua.
-- Keys are Neovim's defaults (K hover, grn rename, gra code action, grr references,
-- gri implementation, grt type definition, gO symbols, [d / ]d diagnostics, <C-s>
-- signature in insert mode, <C-]> definition) plus gd below; which-key lists them.
return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Also loads on :Mason. setup() puts Mason's bin/ on PATH, so it must run before
    -- any server starts, which loading it as a dependency guarantees.
    { "mason-org/mason.nvim", cmd = "Mason", opts = {} },
    "neovim/nvim-lspconfig",
  },
  opts = {
    ensure_installed = {
      "lua_ls",      -- Neovim config
      "bashls",      -- shell scripts, runs shellcheck from the Brewfile
      "vtsls",       -- TypeScript/JavaScript, wraps VS Code's TS extension, uses the project's typescript
      "eslint",      -- the project's eslint.config.js and local eslint
      "tailwindcss", -- class names in TSX/CSS, reads Tailwind 4 @theme tokens
      "jsonls",      -- package.json, tsconfig, other JSON
      "dockerls",    -- Dockerfile
    },
  },
  config = function(_, opts)
    require("mason-lspconfig").setup(opts)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        -- gd jumps straight to a single definition and opens the picker when there are
        -- several. Buffer-local, so gd keeps Vim's meaning where no server is attached.
        if client:supports_method("textDocument/definition") then
          vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end,
            { buffer = ev.buf, desc = "Go to definition" })
        end
      end,
    })
  end,
}
