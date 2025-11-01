# omafish

Recreates [David Heinemeier Hansson](https://dhh.dk/)'s [Omarchy](https://omarchy.org) Bash setup inside [fish shell](https://fishshell.com).

The goal is a 1:1 experience so you can follow DHH's dotfiles and muscle memory while enjoying fish ergonomics.

## Requirements

- [`mise`](https://mise.jdx.dev/) for runtime/toolchain management
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) for smarter directory jumps
- [`starship`](https://starship.rs/) for the prompt

Install and configure these first so the functions provided here can find them.

## Installation

Install via [fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install crmne/omafish
```

Updating follows the same flow:

```fish
fisher update crmne/omafish
```

Once installed, start a new shell session to pick up the configuration.

## License

MIT

## Acknowledgements

Big thanks to DHH for the original [omarchy](https://github.com/basecamp/omarchy) dotfiles.

