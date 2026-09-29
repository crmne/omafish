set -gx SUDO_EDITOR "$EDITOR"
set -gx BAT_THEME ansi

# Color man pages with bat
if command -q bat
    set -gx MANROFFOPT -c
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end
