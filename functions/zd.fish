function zd --description 'cd with zoxide fallback'
    # Plain cd for no args, options and history (cd -), and existing directories
    if test (count $argv) -ne 1; or string match -qr '^-' -- $argv[1]; or test -d $argv[1]
        __omafish_zd_cd $argv
        return $status
    end

    set target (command zoxide query --exclude "$PWD" -- $argv[1] 2>/dev/null)
    if test -z "$target"
        echo "Error: Directory not found"
        return 1
    end

    __omafish_zd_cd $target; or return
    printf "\U000F17A9 "
    pwd
end

# fish's own cd (kept by conf.d/init.fish, with directory history), or the builtin
function __omafish_zd_cd
    if functions -q __omafish_cd
        __omafish_cd $argv
    else
        builtin cd $argv
    end
end
