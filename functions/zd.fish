function zd --description 'cd with zoxide fallback'
    set cd_fn builtin cd
    functions -q __omafish_cd; and set cd_fn __omafish_cd

    # Plain cd for no args, options and history (cd -), and existing directories
    if test (count $argv) -ne 1; or string match -qr '^-' -- $argv[1]; or test -d $argv[1]
        $cd_fn $argv
        return $status
    end

    set target (command zoxide query --exclude "$PWD" -- $argv[1] 2>/dev/null)
    if test -z "$target"
        echo "Error: Directory not found"
        return 1
    end

    $cd_fn $target; or return
    printf "\U000F17A9 "
    pwd
end
