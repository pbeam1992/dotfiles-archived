# dotfiles

Dotfiles managed by [chezmoi](https://www.chezmoi.io/) for two Apple-Silicon Macs (personal and 7peaks work laptop). Packages come from the `Brewfile`. There are no secrets in the repo: SSH private keys stay in 1Password and are served by its SSH agent, and `~/.ssh/config` pins each host to a key by its public `.pub` file.

## Bootstrap (fresh Mac)

0. In the macOS setup assistant, sign into iCloud / the App Store (needed for the `mas` apps).

1. Install Homebrew (also installs Xcode CLT, which provides git):

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"   # for this first session only
   ```

2. Install chezmoi and `gh`, log into the personal GitHub account, and clone this repo. The repo is private and no SSH keys exist yet, so the clone goes over HTTPS through the git credential helper that `gh auth login` sets up (answer yes when it offers to authenticate git):

   ```sh
   brew install chezmoi gh
   gh auth login
   mkdir -p ~/Repositories/github.com/pbeamirl
   git clone https://github.com/pbeamirl/dotfiles.git ~/Repositories/github.com/pbeamirl/dotfiles
   ```

   On the work laptop, add the 7peaks GitHub account afterwards with a second `gh auth login`; `gh auth switch` toggles between the two.

3. Run everything:

   ```sh
   chezmoi init --source ~/Repositories/github.com/pbeamirl/dotfiles --apply
   ```

   You'll be prompted for your **login password** (`chsh` to zsh). `brew bundle` installs all formulae, casks, and App Store apps; trackpad/keyboard/Dock defaults are applied.

   `~/.config/karabiner` is a symlink into the repo. If Karabiner-Elements was already running before this apply, restart its user server once so it watches the new location (per the [Karabiner docs](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)):

   ```sh
   launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.Karabiner-Console-User-Server
   ```

4. Sign into both 1Password accounts (personal and 7peaks) in the app and turn on the SSH agent under Settings → Developer. `~/.config/1Password/ssh/agent.toml` is already applied and names the four keys the agent serves, so `ssh` and `git` work from here on; no key ever needs copying to disk. Commits are signed with the same keys through 1Password (`op-ssh-sign`), so on a new GitHub account add the public key once more as a **Signing Key** (GitHub tracks those separately from authentication keys).

5. Switch this repo's remote to SSH:

   ```sh
   git -C ~/Repositories/github.com/pbeamirl/dotfiles remote set-url origin git@github.com:pbeamirl/dotfiles.git
   ```

6. Open a new terminal and verify:

   ```sh
   chezmoi diff          # should be empty
   brew bundle check     # should be satisfied
   ```

7. Set up herdr's Claude Code integration from inside herdr. It writes `~/.claude/hooks/herdr-agent-state.sh`, which the `SessionStart` hook in `~/.claude/settings.json` already points at; until then that hook is a harmless no-op. The 7peaks profile's `settings.json` already carries the same hook pointing at that script, so no second install is needed.

## Daily use

```sh
chezmoi diff    # what would change
chezmoi apply   # apply configs + run pending install scripts
```

Adding an SSH key: create it as an SSH Key item in 1Password, list its title in `dot_config/private_1Password/private_ssh/agent.toml`, drop its public key in `private_dot_ssh/<title>.pub`, and pin it in `private_dot_ssh/private_config`. Then `chezmoi apply`; the agent picks up `agent.toml` changes without a restart.

Claude Code's `settings.json` (both profiles) and the Karabiner config dir are symlinks into `linked/` in the repo, so app-made edits show up in `git status` rather than `chezmoi diff`, and a `git pull` takes effect without `chezmoi apply`. Zed's `settings.json` is a plain copy (Zed's save would replace a symlink): after changing Zed settings in the UI, `chezmoi re-add ~/.config/zed/settings.json`.

Global agent instructions for Claude Code (both profiles) and Codex all come from `dot_claude/CLAUDE.md`; edit that one file and `chezmoi apply`.

Claude Code skills reach both profiles: `~/.claude-7peaks/skills` is a symlink to `~/.claude/skills`. After `npx skills add <name>`, bring it in with `chezmoi add ~/.agents/skills/<name>` and `chezmoi add ~/.claude/skills/<name>` (canonical copy plus the per-agent symlink the CLI creates).
