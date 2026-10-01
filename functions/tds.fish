function tds --description 'create tmux dev square with editor, diff watch, terminal, and opencode'
    if test (count $argv) -gt 0
        echo "Usage: tds"
        return 1
    end

    # Inside herdr, use the herdr version of this layout
    if test -z "$TMUX"; and set -q HERDR_PANE_ID
        hds $argv
        return
    end

    if test -z "$TMUX"
        echo "You must start tmux or herdr to use tds."
        return 1
    end

    set current_dir "$PWD"
    set editor_pane "$TMUX_PANE"

    tmux rename-window -t "$editor_pane" (basename "$current_dir")

    set terminal_pane (tmux split-window -v -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
    set diff_pane (tmux split-window -h -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
    set opencode_pane (tmux split-window -h -p 50 -t "$terminal_pane" -c "$current_dir" -P -F '#{pane_id}')

    tmux send-keys -t "$editor_pane" -l "nvim ."
    tmux send-keys -t "$editor_pane" C-m
    tmux send-keys -t "$diff_pane" -l "hunk diff --watch"
    tmux send-keys -t "$diff_pane" C-m
    tmux send-keys -t "$opencode_pane" -l opencode
    tmux send-keys -t "$opencode_pane" C-m

    tmux select-pane -t "$editor_pane"
end
