# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

chezmoi dotfiles for two Apple-Silicon Macs: the personal laptop and the 7peaks work laptop. The repo root is the chezmoi source directory (persisted by `.chezmoi.toml.tmpl`). `README.md` covers bootstrap and daily use.

```sh
chezmoi diff        # what apply would change - the main "am I in sync" check
chezmoi apply       # apply source state to $HOME and run pending scripts
chezmoi add <file>  # bring a file in $HOME under management
```

## Layout

- `dot_config/<app>/` → `~/.config/<app>/`. Root-level `run_once_*` / `run_onchange_*` scripts are setup steps; only those using template data keep `.tmpl`. `.chezmoiignore` lists repo-only files; add new ones there.
- `.claude/` is repo-only Claude Code config. chezmoi already skips dot-prefixed source entries; do not list it in `.chezmoiignore`, whose patterns match target paths and would break `~/.claude/settings.json`.
- `linked/` holds real content for targets that are **symlinks into the repo**: both Claude profiles' `settings.json` and the Karabiner directory. Use this only for files the app itself rewrites. Each is wired by a `symlink_<name>.tmpl` containing `{{ .chezmoi.sourceDir }}/linked/<path>`. Their edits show up in `git status`, not `chezmoi diff`, and are live after `git pull` without apply. Karabiner is a directory link because a file link breaks its change detection.
- `dot_claude/CLAUDE.md` is the one global agent-instructions file; `dot_claude-7peaks/CLAUDE.md.tmpl` and `dot_codex/AGENTS.md.tmpl` just `include` it.
- `dot_claude-7peaks/` is the work account's Claude profile (one login per config dir). The `claude()` wrapper in `dot_zshrc` selects it under `~/Repositories/github.com/7-peaks-software/`. Its `settings.json` is a separate copy that may drift, but its herdr `SessionStart` hook line is maintained by hand. `statusline.sh` and `skills` are shared from `~/.claude`.
- Skills: canonical copy in `dot_agents/skills/<name>/`, plus a relative symlink `dot_claude/skills/symlink_<name>` (the `npx skills` layout). After `npx skills add <name>`, `chezmoi add` both `~/.agents/skills/<name>` and `~/.claude/skills/<name>`. Don't make these dirs `exact_`: they hold app-owned entries (`synced/`, the skills lockfile).
- `dot_codex/`, `dot_docker/`: only the listed files are managed; the rest of those homes is app state. `dot_docker/exact_cli-plugins/` wires brew's compose/buildx into the Docker CLI (colima runtime, no Docker Desktop).
- `dot_config/git/`: identities split by `includeIf gitdir:` into `pbeamirl` and `7peaks`, each with its SSH signing key; `useConfigOnly` makes unmatched repos refuse to commit. Claude Code appends to `ignore`, so `chezmoi re-add ~/.config/git/ignore` afterwards.
- `dot_config/nvim/`: one lazy.nvim spec per file in `lua/plugins/`. `lazy-lock.json` is tracked but written by lazy.nvim, so never hand-edit it; `chezmoi re-add` it after updates. Language servers come from Mason's `ensure_installed` in `lsp.lua`. `stylua.toml` is also lua_ls's project marker.
- SSH: private keys live only in 1Password. `agent.toml` must list every pinned key by item title, and `private_dot_ssh/private_config` pins each host to its `.pub`.

## Principles

- **System packages are brew-only**, listed in `Brewfile`. No App Store (`mas`) apps; an app without a cask goes in README's "Manual installs" list. Tools scoped to one program use that program's list (lazy.nvim, Mason); language runtimes use mise.
- **Idempotent scripts.** Never `brew install` in scripts; anything with a side effect checks state first.
- **macOS-only.** Hardcode `/opt/homebrew`, BSD tools, no OS guards.
- **Keep it simple.** No wrappers around chezmoi or brew.
- **No secrets in the repo**, encrypted or not. A config that needs a token becomes a `.tmpl` using `onepasswordRead`. No age encryption.

## Workflow

1. Claude edits source files only: never runs `chezmoi apply` or changes git state.
2. Claude runs `chezmoi diff` and reports what would change.
3. The user runs `chezmoi apply` and verifies.
4. Once confirmed, Claude proposes exact `git commit` / `git push` commands and waits for a yes. If a `linked/` `settings.json` or `dot_claude/CLAUDE.md` is dirty, say what changed and ask whether to include it.
