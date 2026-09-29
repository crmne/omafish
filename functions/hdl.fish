function hdl --description 'create herdr dev layout with editor, AI, and terminal'
    if test (count $argv) -lt 1
        echo "Usage: hdl <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end

    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hdl."
        return 1
    end

    set current_dir "$PWD"
    set editor_pane "$HERDR_PANE_ID"
    set ai $argv[1]
    set ai2 $argv[2]

    herdr tab rename "$HERDR_TAB_ID" (basename "$current_dir") >/dev/null
    __omafish_herdr_split "$editor_pane" down 0.85 "$current_dir" >/dev/null
    set ai_pane (__omafish_herdr_split "$editor_pane" right 0.7 "$current_dir")

    if test -n "$ai2"
        set ai2_pane (__omafish_herdr_split "$ai_pane" down 0.5 "$current_dir")
        herdr pane run "$ai2_pane" "$ai2" >/dev/null
    end

    herdr pane run "$ai_pane" "$ai" >/dev/null
    herdr pane run "$editor_pane" "$EDITOR ." >/dev/null
end
