function ff --wraps=fzf --description 'fzf with file preview'
    if test "$TERM" = xterm-kitty
        fzf --with-shell 'bash -c' --preview 'case $(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac' $argv
    else
        fzf --preview 'bat --style=numbers --color=always {}' $argv
    end
end
