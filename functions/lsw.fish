function lsw --description 'list rsw watchers'
    set found 0
    for line in (pgrep -af 'rsw-watch ')
        set pid (string split -m1 ' ' -- $line)[1]
        set args (string split ' ' -- (string replace -r '.*rsw-watch ' '' -- $line))
        echo "$pid: $args[1] -> $args[-1]"
        set found 1
    end
    test $found -eq 1; or echo "No active watches"
end
