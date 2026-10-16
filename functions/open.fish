function open --description 'Open files and URLs with the platform opener'
    if test (command uname -s) = Darwin
        command open $argv
    else if command -q xdg-open
        command xdg-open $argv >/dev/null 2>&1 &
    else
        printf 'open: no supported opener found (requires macOS open or xdg-open)\n' >&2
        return 127
    end
end
