# dotfiles

Dotfiles managed by [chezmoi](https://www.chezmoi.io/) for two Apple-Silicon Macs (personal and 7peaks work laptop). Apps and packages come from the `Brewfile` (Homebrew only, nothing from the App Store); apps without a Homebrew cask are installed by hand (see [Manual installs](#manual-installs)). There are no secrets in the repo: SSH private keys stay in 1Password and are served by its SSH agent, and `~/.ssh/config` pins each host to a key by its public `.pub` file.

## Bootstrap (fresh Mac)

1. Install Homebrew (also installs Xcode CLT, which provides git):

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"   # for this first session only
   ```

2. Install chezmoi and `gh`, log into the personal GitHub account, and clone this repo. The repo is private and no SSH keys exist yet, so the clone goes over HTTPS. `gh repo clone` authenticates that one git command by itself, so decline when `gh auth login` offers to configure git credentials (saying yes would leave a stray `~/.gitconfig` behind):

   ```sh
   brew install chezmoi gh
   gh auth login
   gh repo clone pbeam1992/dotfiles ~/Repositories/github.com/pbeam1992/dotfiles
   ```

   On the work laptop, add the 7peaks GitHub account afterwards with a second `gh auth login`; `gh auth switch` toggles between the two.

3. Run everything:

   ```sh
   chezmoi init --source ~/Repositories/github.com/pbeam1992/dotfiles --apply
   ```

   `brew bundle` installs all formulae and casks (some cask installers, Karabiner-Elements among them, ask for your login password); the macOS defaults for appearance, trackpad, keyboard, Dock and Finder are applied. If `brew bundle` fails partway, fix the cause and run `chezmoi apply` again: a `run_onchange` script is only recorded as done once it succeeds, and the scripts that sort after it have not run yet.

   `~/.config/karabiner` is a symlink into the repo. If Karabiner-Elements was already running before this apply, restart its user server once so it watches the new location (per the [Karabiner docs](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)):

   ```sh
   launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.Karabiner-Console-User-Server
   ```

   Two things macOS only lets you do by hand: in System Settings → Privacy & Security, allow the Karabiner-Elements driver extension when prompted, and give Hammerspoon Accessibility access (then turn on *Launch Hammerspoon at login* in its preferences). Log out and back in once so dark mode and the keyboard/trackpad defaults take effect everywhere.

4. Sign into both 1Password accounts (personal and 7peaks) in the app and turn on the SSH agent under Settings → Developer. `~/.config/1Password/ssh/agent.toml` is already applied and names the four keys the agent serves, so `ssh` and `git` work from here on; no key ever needs copying to disk. Commits are signed with the same keys through 1Password (`op-ssh-sign`), so on a new GitHub account add the public key once more as a **Signing Key** (GitHub tracks those separately from authentication keys).

5. Switch this repo's remote to SSH:

   ```sh
   git -C ~/Repositories/github.com/pbeam1992/dotfiles remote set-url origin git@github.com:pbeam1992/dotfiles.git
   ```

6. Open a new terminal and verify:

   ```sh
   chezmoi diff             # should be empty
   brew bundle check        # should be satisfied
   ```

7. Install the apps in [Manual installs](#manual-installs).

## Manual installs

Nothing is installed from the App Store. These apps have no Homebrew cask, so install them by hand:

- 1Password for Safari
- Amphetamine
- LINE

Before adding an app here, check `brew search --cask <name>`; if a cask exists, put it in the `Brewfile` instead.

## Daily use

```sh
chezmoi diff    # what would change
chezmoi apply   # apply configs + run pending install scripts
```

Adding an SSH key: create it as an SSH Key item in 1Password, list its title in `dot_config/private_1Password/private_ssh/agent.toml`, drop its public key in `private_dot_ssh/<title>.pub`, and pin it in `private_dot_ssh/private_config`. Then `chezmoi apply`; the agent picks up `agent.toml` changes without a restart.

Claude Code's and the Herdr app's `settings.json` and the Karabiner config dir are symlinks into `linked/` in the repo, so app-made edits show up in `git status` rather than `chezmoi diff`, and a `git pull` takes effect without `chezmoi apply`.

Global agent instructions for Claude Code come from `dot_claude/CLAUDE.md`; edit that file and `chezmoi apply`.
