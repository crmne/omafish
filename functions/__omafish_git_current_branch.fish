function __omafish_git_current_branch --description "Print current branch name"
    command git rev-parse --abbrev-ref HEAD 2>/dev/null
end
