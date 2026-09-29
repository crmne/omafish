function hdlm --description 'create one hdl herdr tab per subdirectory'
    if test (count $argv) -lt 1
        echo "Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end

    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hdlm."
        return 1
    end

    set base_dir "$PWD"
    set hdl_command "hdl "(string escape -- $argv[1..2] | string join ' ')
    set first 1

    herdr workspace rename "$HERDR_WORKSPACE_ID" (basename "$base_dir") >/dev/null

    for dir in "$base_dir"/*/
        test -d "$dir"; or continue
        set dirpath (string replace -r '/$' '' -- "$dir")

        if test $first -eq 1
            # Reuse the current tab for the first project
            herdr pane run "$HERDR_PANE_ID" "cd "(string escape -- $dirpath)"; and $hdl_command" >/dev/null
            set first 0
        else
            set pane_id (herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$dirpath" --no-focus | jq -r '.result.root_pane.pane_id')
            herdr pane run "$pane_id" "$hdl_command" >/dev/null
        end
    end
end
