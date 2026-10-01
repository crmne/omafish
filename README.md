# omafish

My [fish shell](https://fishshell.com) setup. It starts from [Omarchy](https://omarchy.org)'s shell defaults by [David Heinemeier Hansson](https://dhh.dk/), ported 1:1 so the same aliases and muscle memory work in fish, and builds on them with extras of my own.

## Requirements

- [`eza`](https://github.com/eza-community/eza) for a modern alternative to ls
- [`mise`](https://mise.jdx.dev/) for runtime/toolchain management
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) for smarter directory jumps
- [`starship`](https://starship.rs/) for the prompt
- [`fzf`](https://github.com/junegunn/fzf) for fuzzy file and command search

## Installation

1. Install the [Fish shell](https://fishshell.com)
2. Install [fisher](https://github.com/jorgebucaran/fisher)
3. `fisher install crmne/omafish`

Optional (recommended for better keybindings and interactive search UX):

4. `fisher install PatrickF1/fzf.fish`

If you're not on Omarchy, you'll need to copy [starship.toml](starship.toml) to `~/.config/starship.toml`.

## From Omarchy

Everything Omarchy's bash config gives you, as fish functions:

- **Files and directories:** `ls`, `lsa`, `lt`, `lta` (eza), `ff`, `eff`, `sff`, `cd`/`zd` (zoxide fallback), `..`, `...`, `....`, `n`
- **Agents and tools:** `c` (opencode), `cx` (claude), `cy` (codex), `a` (omarchy-agent), `d` (docker), `r` (rails), `t` (tmux), `h` (herdr), `mup`, `open`, `try`
- **Git:** `g`, `gcm`, `gcam`, `gcad` (now abbreviations, see [Git abbreviations](#git-abbreviations)); Omarchy's worktree helpers `ga`/`gd` are `gwa`/`gwd` here, since `ga`/`gd` are `git add`/`git diff`
- **tmux layouts:** `tdl`, `tdlm`, `tds`, `tsl`, and `ic`/`ix`/`icx` (`tdl` with opencode, claude, or both). Inside herdr they run the herdr versions below.
- **herdr layouts:** `hdl`, `hdlm`, `hds`, `hsl`
- **Remote:** `fip`/`dip`/`lip` (SSH port forwarding), `rsw`/`lsw`/`dsw` (rsync on change), and an `ssh` wrapper that cleans up the terminal and reconnects dropped sessions
- **Media:** `img2jpg`, `img2jpg-small`, `img2jpg-medium`, `img2png`, `transcode-video-1080p`, `transcode-video-4K`, `compress`, `decompress`
- **Drives:** `iso2sd`, `format-drive`
- **Environment:** mise, starship, zoxide, and man pages colored with bat

## Extras

Where omafish goes beyond Omarchy:

- **Git abbreviations:** a full, focused set in the oh-my-zsh style. See [below](#git-abbreviations).
- **Agents skip permission prompts:** `cx` runs `claude --dangerously-skip-permissions` and `cy` runs `codex --yolo`.
- **`tdp` and `hdp`: reopen your work, AI conversations included.** `tdlm` needs every project under one folder. `tdp` (tmux) and `hdp` (herdr) save any set of project folders under a name, together with the coding agents running in them. Reopening brings back each window as a `tdl` or `hdl` layout and resumes its conversations, which comes in handy after a reboot or a crash.

  ```fish
  tdp save [name]          # pick this session's windows with fzf (TAB to drop some), then name the profile
  tdp save work --all      # save every window without asking, e.g. from a timer
  tdp work                 # reopen the profile and resume its conversations, inside or outside tmux
  tdp work codex           # start every window fresh with this AI instead
  tdp ls | edit | rm <name>
  hdp ...                  # the same commands for herdr: tabs instead of windows
  ```

  Both commands share the same profiles in `~/.config/tdp/`, so you can save in tmux and reopen in herdr. Each line is a folder followed by its agents, separated by tabs:

  ```
  ~/Code/omafish	claude:3f2b9c1e-...
  ~/Work/api	codex	opencode
  ~/Code/blog
  ```

  - **claude** resumes the exact conversation (`cx --resume <id>`). A claude nobody has typed in yet starts fresh.
  - **codex** and **opencode** don't report which conversation a process is running, so they continue the latest one in that folder (`cy resume --last`, `c --continue`). Two codex or two opencode panes in one folder both get that same conversation.
  - A folder with no agents opens with `cx`.

  herdr can also restore its whole session after a restart by itself: install its agent integrations (`herdr integration install claude`, and so on) and keep `resume_agents_on_restore` on in its config. `hdp` is for opening a chosen set of projects, or a profile saved in tmux.
- **`omarchy` tab completion** for subcommands and their arguments.
- **fish-native `cd`:** the zoxide fallback keeps fish's directory history, so `cd -`, `prevd`/`nextd`, `cdh`, and Alt+←/→ still work.
- **Lazy `try`:** loads on first use, so it adds nothing to shell startup.
- The media functions live on here after Omarchy moved them into `omarchy-transcode`, so they also work off Omarchy.

## Git abbreviations

Abbreviations expand in place when you press space, so you see the full git command before running it. Run `gabbr` to list them all.

### Sample workflows

```fish
# fast commit and push
gaa                            # git add --all
gss                            # git status -s
gcam "Improve sample workflow docs"  # git commit -a -m "Improve sample workflow docs"
gP                             # git push
```

```fish
# sync, branch, and start work
gcom                           # git checkout (__omafish_git_default_branch)
gp                             # git pull
gcb fix-login-bug              # git checkout -b fix-login-bug
```

### Core

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `g` | `git` | Base git command entrypoint. |
| `gcl` | `git clone` | Clone a repository locally. |

### Status

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gst` | `git status` | Full status view with branch and hints. |
| `gss` | `git status -s` | Compact status for quick scans. |

### Branch

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gb` | `git branch -vv` | Inspect local branches and upstream tracking. |
| `gba` | `git branch -a -v` | View local and remote branches together. |
| `gbd!` | `git branch -d` | Delete a branch only if already merged. |
| `gbD!` | `git branch -D` | Force-delete a branch (destructive). |
| `gbm` | `git branch --move` | Rename the current branch or a target branch. |

### Checkout

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gco` | `git checkout` | Switch branches or restore paths. |
| `gcom` | `git checkout (__omafish_git_default_branch)` | Jump back to default branch (`main`/`master`). |
| `gcb` | `git checkout -b` | Create and switch to a new branch. |

### Commit

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gc` | `git commit -v` | Commit with diff context in editor. |
| `gc!` | `git commit -v --amend` | Amend the previous commit. |
| `gcn!` | `git commit -v --no-edit --amend` | Amend without editing the message. |
| `gca` | `git commit -v -a` | Commit tracked-file changes without explicit `add`. |
| `gca!` | `git commit -v -a --amend` | Amend previous commit including tracked changes. |
| `gcan!` | `git commit -v -a --no-edit --amend` | Fast amend of tracked changes, keep message. |
| `gcv` | `git commit -v --no-verify` | Skip commit hooks when necessary. |
| `gcav` | `git commit -a -v --no-verify` | Commit tracked changes and skip hooks. |
| `gcav!` | `git commit -a -v --no-verify --amend` | Amend while skipping hooks. |
| `gcm` | `git commit -m` | Quick commit with inline message. |
| `gcam` | `git commit -a -m` | One-liner commit for tracked changes. |
| `gcad` | `git commit -a --amend` | Amend with all tracked changes (Omarchy's alias). |

### Diff and log

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gd` | `git diff` | Review unstaged changes. |
| `gdc` | `git diff --cached` | Review staged changes before commit. |
| `gl` | `git log` | Browse commit history with full details. |
| `gls` | `git log --stat` | See commit history with file-change stats. |
| `glg` | `git log --oneline --decorate --color --graph` | Compact visual graph of branch history. |

### Pull and push

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gp` | `git pull` | Pull latest changes from remote. |
| `gup` | `git pull --rebase` | Keep history linear while updating. |
| `gP` | `git push` | Push current branch to remote. |
| `gP!` | `git push --force-with-lease` | Safe-force push after rewrite (destructive). |
| `gPn` | `git push --no-verify` | Push while skipping push hooks. |
| `gPn!` | `git push --no-verify --force-with-lease` | Force-with-lease + no hooks (destructive). |
| `gpu` | `git push origin (__omafish_git_current_branch) --set-upstream` | First push of a new branch with upstream set. |
| `gpa` | `git push origin --all` | Push all local branches to origin. |
| `gpt` | `git push origin --tags` | Push tags to origin. |

### Rebase

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gr` | `git rebase` | Reapply commits onto a new base. |
| `gra` | `git rebase --abort` | Exit and undo an in-progress rebase. |
| `grc` | `git rebase --continue` | Continue after resolving rebase conflicts. |
| `gri` | `git rebase --interactive` | Reorder/squash/edit commits before sharing. |

### Stash

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gsta` | `git stash` | Temporarily shelve working changes. |
| `gstp` | `git stash pop` | Reapply the latest stash and remove it. |
| `gstl` | `git stash list` | View saved stash entries. |
| `gstd` | `git stash drop` | Remove a stash entry you no longer need. |

### Local file ops

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `ga` | `git add` | Stage selected files. |
| `gaa` | `git add --all` | Stage all tracked/untracked changes. |
| `grm` | `git rm` | Remove file from working tree and index. |
| `grmc` | `git rm --cached` | Untrack file but keep it locally. |

### Safety-sensitive

| Abbreviation | Command | Why/When |
| --- | --- | --- |
| `gclean` | `git clean -di` | Interactively remove untracked files/dirs. |
| `gclean!` | `git clean -dfx` | Remove all untracked + ignored files (destructive). |
| `gclean!!` | `git reset --hard; and git clean -dfx` | Full reset to pristine state (very destructive). |
| `gm` | `git merge` | Merge another branch into current branch. |
| `grf` | `git revert` | Undo a commit by creating a new inverse commit. |
| `grp!` | `git reset --hard HEAD` | Discard local tracked-file changes (destructive). |

## Update

```fish
fisher update crmne/omafish
```

## License

MIT

## Acknowledgements

Big thanks to DHH for the original [omarchy](https://github.com/basecamp/omarchy) dotfiles.
