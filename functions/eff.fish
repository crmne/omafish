function eff --description 'edit file chosen via ff'
    set picked (ff)
    if test -n "$picked"
        $EDITOR "$picked"
    end
end
