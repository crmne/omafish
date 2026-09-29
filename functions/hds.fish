function hds --description 'create herdr dev square with editor, diff watch, terminal, and opencode'
    if test (count $argv) -gt 0
        echo "Usage: hds"
        return 1
    end

    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hds."
        return 1
    end

    set current_dir "$PWD"
    set editor_pane "$HERDR_PANE_ID"

    herdr tab rename "$HERDR_TAB_ID" (basename "$current_dir") >/dev/null

    set terminal_pane (__omafish_herdr_split "$editor_pane" down 0.5 "$current_dir")
    set diff_pane (__omafish_herdr_split "$editor_pane" right 0.5 "$current_dir")
    set opencode_pane (__omafish_herdr_split "$terminal_pane" right 0.5 "$current_dir")

    herdr pane run "$editor_pane" "nvim ." >/dev/null
    herdr pane run "$diff_pane" "hunk diff --watch" >/dev/null
    herdr pane run "$opencode_pane" opencode >/dev/null
end
