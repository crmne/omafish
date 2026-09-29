function gwa --description 'create a git worktree and branch next to the current repo'
    if test (count $argv) -eq 0
        echo "Usage: gwa [branch name]"
        return 1
    end

    set branch $argv[1]
    set wt_path "../"(basename "$PWD")"--$branch"

    git worktree add -b "$branch" "$wt_path"
    and mise trust "$wt_path"
    and cd "$wt_path"
end
