# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Dotfiles managed by **chezmoi** for two Apple-Silicon Macs: the personal laptop and the 7peaks work laptop. The repo root is the chezmoi source directory (a non-default location, persisted in `~/.config/chezmoi/chezmoi.toml` by `.chezmoi.toml.tmpl`). This repo owns app configs; package installation is brew-only — packages go in `Brewfile`. There are no OS guards: everything here assumes macOS and `/opt/homebrew`.

## Commands

```sh
chezmoi apply       # apply source state to $HOME (also runs pending scripts)
chezmoi diff        # what apply would change — the main "am I in sync" check
chezmoi add <file>  # bring an existing file in $HOME under management

# Bootstrap on a new machine (one time; persists sourceDir):
chezmoi init --source ~/Repositories/github.com/pbeamirl/dotfiles --apply
```

## Layout

- Repo root = chezmoi source root. App configs live under `dot_config/<app>/` (→ `~/.config/<app>/`).
- `linked/` — real content for the few targets that are **symlinks into this repo** rather than copies: `linked/claude/settings.json`, `linked/claude-7peaks/settings.json` and the `linked/karabiner/` directory. These files are rewritten by their own app (Claude Code's `/model` and `/config`, herdr's hook install, Karabiner's device list and UI), so a copy would drift and need `chezmoi re-add` after every rewrite; with a symlink the app edits the git-tracked file and the change shows up in `git status`. The pattern is chezmoi's documented one: `linked` is listed in `.chezmoiignore`, and a `symlink_<name>.tmpl` next to the target's siblings holds `{{ .chezmoi.sourceDir }}/linked/<path>`. Consequences: `chezmoi diff` no longer reports content changes to these files (only a missing or replaced link); after `git pull` the change is live without `chezmoi apply`; `private_`/`executable_` have no effect on symlink entries. Karabiner is a *directory* link because a symlinked `karabiner.json` breaks its change detection (per its docs), so `linked/karabiner/automatic_backups/` is git-ignored. Zed's `settings.json` deliberately stays a copy: Zed saves via temp-file-and-rename, which replaces a file symlink. Do not add more symlinks into `linked/` without the same "app rewrites it" reason. The one other symlink kind is different: `dot_claude-7peaks/symlink_skills.tmpl` points at `~/.claude/skills`, not into the repo, so the 7peaks profile shares a directory the personal profile owns (see below).
- `dot_claude/` → `~/.claude/` (user-level `CLAUDE.md`, the one global agent-instructions file, included verbatim by `dot_claude-7peaks/CLAUDE.md.tmpl` and `dot_codex/AGENTS.md.tmpl`, so edit it here and every agent gets it; `symlink_settings.json.tmpl` → `linked/claude/settings.json`, `executable_statusline.sh` — the Claude Code status line — and `skills/`, one entry per skill; `agents/` and `keybindings.json` go here the same way when they are needed). Skills follow the layout the `skills` CLI (vercel-labs/skills, `npx skills add`) writes: the canonical copy lives in `~/.agents/skills/<name>/` (`dot_agents/skills/`), and `~/.claude/skills/<name>` is a relative symlink to it (`dot_claude/skills/symlink_<name>`), so the CLI keeps working. After `npx skills add <name>`, run `chezmoi add ~/.agents/skills/<name>` and `chezmoi add ~/.claude/skills/<name>`. A hand-written skill can simply be a real `dot_claude/skills/<name>/SKILL.md`. Neither directory gets the `exact_` prefix: Claude Code keeps claude.ai-synced skills in `~/.claude/skills/synced/`, and the CLI keeps its lockfile at `~/.agents/.skill-lock.json` (not managed; it is installer state). Claude Code edits `settings.json` itself (`/model`, `/config`), and herdr's Claude integration adds a `SessionStart` hook pointing at `~/.claude/hooks/herdr-agent-state.sh` (herdr-managed, not in this repo); both land in `linked/claude/settings.json` directly. Because those edits are often machine-local, `.claude/settings.json` registers a `PreToolUse` hook (`.claude/hooks/guard-claude-settings.sh`) that turns any `git commit`/`git add` including either profile's `settings.json` or `dot_claude/CLAUDE.md` into a permission prompt showing its diff.
- `dot_claude-7peaks/` → `~/.claude-7peaks/`, the **7peaks work account's** Claude Code profile. The 7peaks seat is a separate Claude subscription, and Claude Code stores exactly one login per config directory, so the two accounts need two directories. The `claude()` wrapper in `dot_zshrc` sets `CLAUDE_CONFIG_DIR` to this one for anything under `~/Repositories/github.com/7-peaks-software/`, mirroring the per-directory git identity split in `dot_config/git/config`; `claude-personal` (or `CC_ACCOUNT=personal`) opts back out inside a work repo. `linked/claude-7peaks/settings.json` is a deliberate copy of its `linked/claude/` counterpart — Claude Code rewrites `settings.json` in place, so each profile needs its own file, and the two may legitimately drift. `CLAUDE.md.tmpl` is a one-line `include` of `dot_claude/CLAUDE.md`, so edit that one. `statusline.sh` is *not* copied: both profiles' `settings.json` point at the absolute `~/.claude/statusline.sh`, and that script derives its cache path and Keychain service name from `$CLAUDE_CONFIG_DIR` so each profile reports its own usage. `symlink_skills.tmpl` → `~/.claude/skills` follows the same idea: skills are installed or authored once for the personal profile and the 7peaks profile reads the whole personal directory through the link, so a skill added with `npx skills add` is visible there with no chezmoi change, and so are claude.ai-synced skills under `~/.claude/skills/synced/`. The 7peaks `settings.json` carries the same herdr `SessionStart` hook as the personal one, pointing at the shared `~/.claude/hooks/herdr-agent-state.sh`; herdr only installs into the default profile, so that line is maintained by hand.
- `dot_codex/` → `~/.codex/`, the Codex home. Codex here is the desktop app bundled inside `/Applications/ChatGPT.app` (not brew), and it reads `~/.codex/AGENTS.md` as its global instructions, so `AGENTS.md.tmpl` is a one-line `include` of `dot_claude/CLAUDE.md`. Only that file is managed; the rest of `~/.codex/` (`config.toml`, `auth.json`, caches, sqlite state) is app-written, hence no `exact_` prefix.
- `.claude/` — repo-only Claude Code config (the commit guard above). chezmoi skips dot-prefixed source entries, so it is never applied to `$HOME`; do *not* list it in `.chezmoiignore`, whose patterns match target paths and would break the real `~/.claude/settings.json`.
- `dot_config/git/` — `config` holds shared behavior plus the two `includeIf gitdir:` rules; the per-account identities live in `pbeamirl` and `7peaks`. `user.useConfigOnly = true` means a repo matching neither rule refuses to commit rather than guessing an author. `ignore` is the global excludes file (git reads it by default under XDG); Claude Code appends to it, so `chezmoi re-add ~/.config/git/ignore` after it does.
- `Brewfile` — the single list of brew-managed packages. Adding a package = one line here; `run_onchange_install-packages.sh.tmpl` re-runs `brew bundle` when it changes.
- `run_once_*` / `run_onchange_*` scripts — setup steps chezmoi runs for us. Only the ones that use template data keep a `.tmpl` suffix. `run_onchange_after_install-mise-tools.sh.tmpl` is `after_` so it runs once `install-packages` has put mise on PATH; its `command -v mise` guard is only a backstop.
- `.chezmoiignore` — repo-only files (README, this file, Brewfile) that must not be applied to `$HOME`; add new repo-only files there.

## Principles

- **Installation is brew-only.** Never add other installers here; `brew bundle` is the whole story.
- **Idempotent by construction.** Lean on tools that already are: `brew bundle` skips installed packages — never `brew install` in scripts. Any `run_*` script must check current state before mutating (see `run_once_set-default-shell.sh`).
- **macOS-only.** Both machines are Apple-Silicon Macs: hardcode `/opt/homebrew`, use BSD `date`/`stat`, no `{{ if eq .chezmoi.os … }}` guards, no Linux fallbacks.
- **Keep it simple.** No wrapper scripts around chezmoi or brew; the flat layout above is the whole structure.

## Workflow

1. Claude edits source files in this repo (never runs `chezmoi apply`, never touches git state).
2. Claude runs `chezmoi diff` and reports what would change.
3. The user runs `chezmoi apply` themselves and verifies the result.
4. Once the user confirms, Claude proposes the exact `git commit` / `git push` commands, waits for a yes, then runs them. If either profile's `settings.json` under `linked/` or `dot_claude/CLAUDE.md` is dirty, say what changed in it and ask whether to include it before proposing the commit.
