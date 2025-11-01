# omafish

Recreates [David Heinemeier Hansson](https://dhh.dk/)'s [Omarchy](https://omarchy.org) Bash setup inside [fish shell](https://fishshell.com).

The goal is a 1:1 experience so you can follow DHH's dotfiles and muscle memory while enjoying fish ergonomics.

## Requirements

- [`eza`](https://github.com/eza-community/eza) for a modern alternative to ls
- [`mise`](https://mise.jdx.dev/) for runtime/toolchain management
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) for smarter directory jumps
- [`starship`](https://starship.rs/) for the prompt
- [`fzf`](https://github.com/junegunn/fzf) for fuzzy file and command search

## Installation

1. Install the [Fish shell](https://fishshell.com)
2. Install [fisher](https://github.com/jorgebucaran/fisher)
3. `fisher install PatrickF1/fzf.fish`
4. `fisher install crmne/omafish`

If you're not on Omarchy, you'll need to copy [starship.toml](starship.toml) to `~/.config/starship.toml`.

## Update

```fish
fisher update crmne/omafish
```

## License

MIT

## Acknowledgements

Big thanks to DHH for the original [omarchy](https://github.com/basecamp/omarchy) dotfiles.
