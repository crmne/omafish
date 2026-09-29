# Wrap ssh to clean up the terminal and reconnect when a connection drops.
#
# A remote tmux, herdr, or editor arms terminal modes over the SSH pipe (mouse
# tracking, focus reporting, the alternate screen) that only it can disarm. If
# the connection dies instead of exiting cleanly, those modes stay armed on the
# local terminal, and every mouse move floods the prompt with escape junk.
function ssh --description 'ssh that cleans up the terminal and reconnects dropped sessions'
    set started (date +%s)
    command ssh $argv
    set rc $status

    isatty stdout; or return $rc
    __omafish_ssh_disarm

    # Reconnect only when an interactive session drops: ssh exits 255 for
    # transport failures, but a fast 255 with no established session is a
    # connect/auth failure, a remote command's own 255 passes through
    # indistinguishably and must not replay its side effects, and redirected
    # stdin would feed the remaining piped input to a fresh remote shell.
    if test $rc -ne 255; or not isatty stdin; or not __omafish_ssh_interactive $argv
        or test (math (date +%s) - $started) -lt 30
        return $rc
    end

    # Ctrl-C cancels both the in-flight attempt and the loop itself. Keep
    # retrying fast failures, since a rebooting server refuses connections too.
    while true
        echo "Connection lost. Reconnecting (Ctrl-C to stop)..."
        sleep 2; or return 130
        command ssh $argv
        set rc $status
        __omafish_ssh_disarm
        test $rc -ne 255; and return $rc
    end
end

# Disarm mouse tracking (1000/1002/1003, 1006 encoding), focus reporting
# (1004), and the alternate screen (1049), and show the cursor again.
function __omafish_ssh_disarm
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
end

# True for an interactive session: a destination and no remote command. The
# letters are the ssh(1) options that consume a value, so their arguments are
# not mistaken for the destination.
function __omafish_ssh_interactive
    set value_opts BbcDEeFIiJLlmOoPpQRSWw
    set argv_all $argv
    set dest
    set opts_done
    set skip_next

    for arg in $argv
        if test -n "$skip_next"
            set skip_next
        else if test -z "$opts_done"; and test "$arg" = --
            set opts_done 1
        else if test -z "$opts_done"; and string match -qr '^-.' -- $arg
            set letters (string split '' -- (string sub -s 2 -- $arg))
            for i in (seq (count $letters))
                if string match -q "*$letters[$i]*" -- $value_opts
                    # The value is glued to the letter (-p2222) unless the letter ends
                    # the argument, in which case it consumes the next one (-p 2222).
                    test $i -eq (count $letters); and set skip_next 1
                    break
                end
            end
        else if test -z "$dest"
            set dest $arg
        else
            return 1
        end
    end

    test -n "$dest"; or return 1

    # A RemoteCommand from ssh_config or -o replays on reconnect just like a
    # positional command; ssh -G resolves the effective configuration for this
    # exact invocation without connecting. Fail closed when it cannot resolve,
    # since an undetected RemoteCommand must not replay. The explicit "none"
    # cancels a configured command, and some versions emit it when unset.
    set resolved (command ssh -G $argv_all 2>/dev/null); or return 1
    not string match -qir '^remotecommand (?!none$)' -- $resolved
end
