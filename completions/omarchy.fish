# Complete the omarchy dispatcher from the omarchy-* commands next to it, and
# from the `# omarchy:args=` spec in the resolved command for its arguments.
function __omafish_omarchy_complete
    set omarchy_path (command -s omarchy); or return
    set bin_dir (path dirname (path resolve $omarchy_path))

    set words (commandline -opc)[2..-1]
    set words (string match -v -- '-*' $words)

    # Next subcommand word for the current prefix
    set prefix (string join - omarchy $words)
    set candidates (path basename $bin_dir/$prefix-* | string replace -- "$prefix-" '' | string replace -r -- '-.*' '' | sort -u)
    test (count $words) -eq 0; and set -a candidates commands
    if test "$words[1]" = commands
        set -a candidates --all --json --markdown --check
    end

    if test (count $candidates) -gt 0
        printf '%s\n' $candidates
        return
    end

    # No deeper subcommand: find the longest command the words resolve to
    # and offer the literal words or enum values from its args spec.
    set all_words (commandline -opc)[2..-1]
    for n in (seq (count $words) -1 0)
        set command_path $bin_dir/(string join - omarchy $words[1..$n])
        test $n -eq 0; and set command_path $bin_dir/omarchy
        test -x $command_path; or continue

        set spec (string match -rg '^# omarchy:args=(.*)' <$command_path)
        test -n "$spec"; or return
        set given (math (count $all_words) - $n)

        for alt in (string split ' | ' -- $spec)
            set tokens (string split -n ' ' -- $alt)
            set token $tokens[(math $given + 1)]
            test -n "$token"; or continue
            set value (string trim -c '<>[]' -- $token)
            if string match -q '*|*' -- $value
                string split '|' -- $value
            else if not string match -qr '^[<\[]' -- $token
                echo $token
            end
        end
        return
    end
end

complete -c omarchy -f -a '(__omafish_omarchy_complete)'
complete -c omarchy -n 'test -z "$(__omafish_omarchy_complete)"' -F
