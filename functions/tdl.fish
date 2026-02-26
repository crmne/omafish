function tdl --description 'create tmux dev layout with editor, AI, and terminal'
    if test (count $argv) -lt 1
        echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end

    if test -z "$TMUX"
        echo "You must start tmux to use tdl."
        return 1
    end

    set current_dir "$PWD"
    set editor_pane "$TMUX_PANE"
    set ai $argv[1]
    set ai2 $argv[2]

    tmux rename-window -t "$editor_pane" (basename "$current_dir")
    tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

    set ai_pane (tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

    if test -n "$ai2"
        set ai2_pane (tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
        tmux send-keys -t "$ai2_pane" "$ai2" C-m
    end

    tmux send-keys -t "$ai_pane" "$ai" C-m
    tmux send-keys -t "$editor_pane" "$EDITOR ." C-m
    tmux select-pane -t "$editor_pane"
end
