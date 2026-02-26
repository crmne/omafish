function tdlm --description 'create one tdl tmux window per subdirectory'
    if test (count $argv) -lt 1
        echo "Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end

    if test -z "$TMUX"
        echo "You must start tmux to use tdlm."
        return 1
    end

    set ai $argv[1]
    set ai2 $argv[2]
    set base_dir "$PWD"
    set first 1

    set session_name (basename "$base_dir" | string replace -a "." "-" | string replace -a ":" "-")
    tmux rename-session "$session_name"

    for dir in "$base_dir"/*/
        if test -d "$dir"
            set dirpath (string replace -r '/$' '' -- "$dir")

            if test $first -eq 1
                tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
                set first 0
            else
                set pane_id (tmux new-window -c "$dirpath" -P -F '#{pane_id}')
                tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
            end
        end
    end
end
