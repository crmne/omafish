function open --description 'open files/urls via xdg-open'
    xdg-open $argv >/dev/null 2>&1 &
end
