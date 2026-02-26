function cd --wraps=zd --description 'alias cd=zd'
    if command -q zoxide
        zd $argv
    else
        builtin cd $argv
    end
end
