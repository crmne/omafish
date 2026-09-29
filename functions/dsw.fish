function dsw --description 'stop all rsw watchers'
    set found 0
    for pid in (pgrep -f 'rsw-watch ')
        kill -- -$pid 2>/dev/null
        and echo "Stopped watch (pid $pid)"
        and set found 1
    end
    test $found -eq 1; or echo "No active watches"
end
