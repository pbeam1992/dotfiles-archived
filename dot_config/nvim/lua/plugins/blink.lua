-- blink.cmp: completion menu as you type, with fuzzy matching, a docs window beside the
-- menu and parameter hints while typing a call. Keys ("enter" preset): <CR> accepts,
-- <C-n>/<C-p> or arrows move, <C-e> closes, <C-space> opens it by hand, <Tab>/<S-Tab>
-- jump between snippet placeholders.
-- Release tags ship a prebuilt Rust fuzzy matcher, so there is no build step.
-- Loaded when a file opens rather than on InsertEnter: blink tells every language server
-- what the menu supports, and a server started before blink loads never hears it.
-- Sources are blink's defaults (LSP, path, snippets, buffer); lazydev's source is the
-- next thing to explore.
return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    keymap = { preset = "enter" },
    completion = { documentation = { auto_show = true } },
    signature = { enabled = true },
  },
}
