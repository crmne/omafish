function gwd --description 'remove the current git worktree and its branch'
    gum confirm "Remove worktree and branch?"; or return

    set cwd "$PWD"
    set worktree (basename "$cwd")

    # Split on the first `--`
    set root (string split -m1 -- -- "$worktree")[1]
    set branch (string split -m1 -- -- "$worktree")[2]

    # Protect against accidentally nuking a non-worktree directory
    if test "$root" != "$worktree"
        cd "../$root"
        git worktree remove "$cwd" --force; or return 1
        git branch -D "$branch"
    end
end
