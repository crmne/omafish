function __omafish_git_default_branch --description "Resolve repo default branch"
    set -l configured (command git config --get init.defaultBranch 2>/dev/null)
    if test -n "$configured"
        if command git show-ref --verify --quiet "refs/heads/$configured"
            echo $configured
            return 0
        end
    end

    if command git show-ref --verify --quiet refs/heads/main
        echo main
    else if command git show-ref --verify --quiet refs/heads/master
        echo master
    else
        echo main
    end
end
