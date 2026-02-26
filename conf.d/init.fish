if status is-interactive
    if command -q mise
        mise activate fish | source
    end

    if command -q starship
        starship init fish | source
    end

    if command -q zoxide
        zoxide init fish | source
    end

    if command -q try
        try init ~/Work/tries | source
    end
end
