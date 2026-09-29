if status is-interactive
    if command -q mise
        mise activate fish | source
    end

    if command -q starship
        starship init fish | source
    end

    if command -q zoxide
        zoxide init fish | source

        # Keep fish's own cd (directory history, cd -, prevd/nextd) for zd to build on
        if not functions -q __omafish_cd
            and string match -q -r '^embedded:|^/usr/share/fish/' -- (functions --details cd)
            functions --copy cd __omafish_cd
        end

        function cd --wraps=zd --description 'alias cd=zd'
            zd $argv
        end
    end

    # Load try on first use so it adds nothing to shell startup
    if command -q try
        function try
            functions -e try
            SHELL=(status fish-path) command try init ~/Work/tries | source
            try $argv
        end
    end
end
