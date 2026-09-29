function tdp --description 'save and open named profiles of tdl windows'
    set -l profiles ~/.config/tdp

    switch "$argv[1]"
        case '' ls list
            mkdir -p $profiles
            for f in $profiles/*
                test -f $f; or continue
                printf '%-16s %s windows\n' (basename $f) (string match -rv '^\s*(#|$)' <$f | count)
            end

        case save
            if test -z "$TMUX"
                echo "You must be inside tmux to save a profile."
                return 1
            end

            # One row per window: the path of its first pane (the editor in a tdl layout)
            set -l dirs
            for win in (tmux list-windows -F '#{window_id}')
                set -a dirs (tmux list-panes -t $win -F '#{pane_current_path}' | head -1)
            end
            set dirs (printf '%s\n' $dirs | awk '!seen[$0]++' | string replace -r "^$HOME" '~')

            set -l picked (printf '%s\n' $dirs | fzf --multi --bind 'start:select-all' \
                --header 'TAB toggles a window, ENTER saves the selected ones' --prompt 'windows> ')
            if test (count $picked) -eq 0
                echo "Nothing selected, not saving."
                return 1
            end

            set -l name $argv[2]
            if test -z "$name"
                read -P 'Profile name: ' name; or return 1
            end
            set name (string replace -ra '[/\s]' '-' -- $name)
            test -n "$name"; or return 1

            mkdir -p $profiles
            if test -e $profiles/$name
                read -P "Profile '$name' exists. Overwrite? [y/N] " -l answer
                string match -qi 'y*' -- $answer; or return 1
            end

            printf '%s\n' $picked >$profiles/$name
            echo "Saved '$name' with "(count $picked)" windows to $profiles/$name"

        case edit
            test -n "$argv[2]"; or begin
                echo "Usage: tdp edit <profile>"
                return 1
            end
            mkdir -p $profiles
            $EDITOR $profiles/$argv[2]

        case rm
            test -f "$profiles/$argv[2]"; or begin
                echo "No profile '$argv[2]'."
                return 1
            end
            rm $profiles/$argv[2]
            echo "Removed '$argv[2]'."

        case '*'
            # tdp [open] <profile> [<ai>] [<second_ai>]
            test "$argv[1]" = open; and set -e argv[1]
            set -l name $argv[1]
            set -l file $profiles/$name
            if not test -f "$file"
                echo "No profile '$name'. Profiles:"
                tdp ls
                return 1
            end

            set -l ai $argv[2]
            test -n "$ai"; or set ai cx
            set -l tdl_cmd "tdl $ai $argv[3]"

            set -l dirs
            for line in (string match -rv '^\s*(#|$)' <$file)
                set -l dir (string replace -r '^~' $HOME -- (string trim -- $line))
                if test -d "$dir"
                    set -a dirs $dir
                else
                    echo "Skipping missing directory: $line"
                end
            end
            if test (count $dirs) -eq 0
                echo "Profile '$name' has no existing directories."
                return 1
            end

            set -l session (string replace -ra '[.:]' '-' -- $name)
            set -l current_session
            test -n "$TMUX"; and set current_session (tmux display -p '#S')

            # Already open elsewhere: just go there
            if tmux has-session -t "=$session" 2>/dev/null; and test "$session" != "$current_session"
                if test -n "$TMUX"
                    tmux switch-client -t "=$session"
                else
                    tmux attach -t "=$session"
                end
                return
            end

            if test -n "$TMUX"
                # Like tdlm: take over the current session and reuse this window for the first project
                tmux rename-session "$session"
                tmux send-keys -t "$TMUX_PANE" "cd "(string escape -- $dirs[1])"; and $tdl_cmd" C-m
                for dir in $dirs[2..-1]
                    set -l pane (tmux new-window -d -t "$session:" -c "$dir" -P -F '#{pane_id}')
                    tmux send-keys -t "$pane" "$tdl_cmd" C-m
                end
            else
                for dir in $dirs
                    set -l pane
                    if tmux has-session -t "=$session" 2>/dev/null
                        set pane (tmux new-window -d -t "$session:" -c "$dir" -P -F '#{pane_id}')
                    else
                        set pane (tmux new-session -d -s "$session" -c "$dir" -P -F '#{pane_id}')
                    end
                    tmux send-keys -t "$pane" "$tdl_cmd" C-m
                end
                tmux attach -t "=$session"
            end
    end
end
