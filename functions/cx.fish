function cx --description 'clear terminal and run claude with permissive mode'
    printf "\033[2J\033[3J\033[H"
    claude --allow-dangerously-skip-permissions $argv
end
