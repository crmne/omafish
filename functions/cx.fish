function cx --wraps=claude --description 'clear terminal and run claude skipping permission prompts'
    printf "\033[2J\033[3J\033[H"
    command claude --dangerously-skip-permissions $argv
end
