# Shared engine behind tdp (tmux) and hdp (herdr).
#
# A profile is a text file in ~/.config/tdp/, one window per line: the folder,
# then up to two agents separated by tabs. An agent is `claude:<session id>`,
# `claude`, `codex`, or `opencode`. A line with only a folder opens with cx.
#
# Usage: __omafish_profiles <tmux|herdr> <command> [args...]
function __omafish_profiles
    set -l backend $argv[1]
    set -l self (string sub -l 1 -- $backend)dp
    set -l layout (string sub -l 1 -- $backend)dl
    set -l profiles ~/.config/tdp

    switch "$argv[2]"
        case '' ls list
            mkdir -p $profiles
            for f in $profiles/*
                test -f $f; or continue
                set -l lines (string match -rv '^\s*(#|$)' <$f)
                set -l agents (string split \t -- $lines | string match -r '^(?:claude|codex|opencode)' | count)
                printf '%-16s %s windows, %s agents\n' (basename $f) (count $lines) $agents
            end

        case save
            set -l name
            set -l all 0
            for arg in $argv[3..-1]
                switch $arg
                    case -a --all
                        set all 1
                    case '*'
                        set name $arg
                end
            end

            set -l windows_fn __omafish_profiles_$backend"_windows"
            set -l rows ($windows_fn); or return 1
            if test (count $rows) -eq 0
                echo "No windows to save."
                return 1
            end

            # rows: folder TAB agent kinds TAB ref1 TAB ref2; show the first two fields
            set -l picked $rows
            if test $all -eq 0
                # Show each folder padded to one column, then its agents
                set -l width (string split -f1 \t -- $rows | string length | sort -n | tail -1)
                set -l display
                for row in $rows
                    set -l fields (string split \t -- $row)
                    set -a display (string pad -r -w $width -- $fields[1])"  $fields[2]"\t$row
                end
                set picked (printf '%s\n' $display | fzf --multi --layout=reverse --bind 'load:select-all' \
                    --delimiter \t --with-nth 1 \
                    --header 'TAB toggles a window, ENTER saves the selected ones' --prompt 'windows> ' \
                    | string replace -r '^[^\t]*\t' '')
            end
            if test (count $picked) -eq 0
                echo "Nothing selected, not saving."
                return 1
            end

            if test -z "$name"
                read -P 'Profile name: ' name; or return 1
            end
            set name (string replace -ra '[/\s]' '-' -- $name)
            test -n "$name"; or return 1

            mkdir -p $profiles
            if test $all -eq 0; and test -e $profiles/$name
                read -P "Profile '$name' exists. Overwrite? [y/N] " -l answer
                string match -qi 'y*' -- $answer; or return 1
            end

            for row in $picked
                set -l fields (string split \t -- $row)
                string join \t -- $fields[1] $fields[3..-1]
            end >$profiles/$name
            echo "Saved '$name' with "(count $picked)" windows to $profiles/$name"

        case edit
            test -n "$argv[3]"; or begin
                echo "Usage: $self edit <profile>"
                return 1
            end
            mkdir -p $profiles
            $EDITOR $profiles/$argv[3]

        case rm
            test -f "$profiles/$argv[3]"; or begin
                echo "No profile '$argv[3]'."
                return 1
            end
            rm $profiles/$argv[3]
            echo "Removed '$argv[3]'."

        case '*'
            # <self> [open] <profile> [<ai>] [<second_ai>]
            set -l args $argv[2..-1]
            test "$args[1]" = open; and set -e args[1]
            set -l name $args[1]
            set -l file $profiles/$name
            if not test -f "$file"
                echo "No profile '$name'. Profiles:"
                __omafish_profiles $backend ls
                return 1
            end

            # An explicit AI starts every window fresh with it
            set -l override $args[2..3]

            set -l windows
            for line in (string match -rv '^\s*(#|$)' <$file)
                set -l fields (string split \t -- (string trim -- $line))
                set -l dir (string replace -r '^~' $HOME -- $fields[1])
                if not test -d "$dir"
                    echo "Skipping missing directory: $fields[1]"
                    continue
                end

                set -l ais $override
                if test (count $ais) -eq 0
                    for ref in $fields[2..3]
                        set -a ais (__omafish_profiles_resume_command $ref)
                    end
                end
                test (count $ais) -gt 0; or set ais cx

                set -a windows $dir (string join ' ' -- $layout (string escape -- $ais))
            end
            if test (count $windows) -eq 0
                echo "Profile '$name' has no existing directories."
                return 1
            end

            set -l open_fn __omafish_profiles_$backend"_open"
            $open_fn (string replace -ra '[.:]' '-' -- $name) $windows
    end
end

# The command that brings an agent back: the exact claude conversation, or for
# codex and opencode, which don't say which one is running, the latest
# conversation in the folder. A claude without a conversation starts fresh.
function __omafish_profiles_resume_command --argument ref
    switch $ref
        case 'claude:*'
            echo "cx --resume "(string replace 'claude:' '' -- $ref)
        case claude
            echo cx
        case codex
            echo "cy resume --last"
        case opencode
            echo "c --continue"
    end
end

# Print a reference for each coding agent running under a shell pid, in order:
# `claude:<session id>` (or `claude`), `codex`, or `opencode`.
function __omafish_profiles_agents --argument shell_pid
    set -l claude_dir ~/.claude
    set -q CLAUDE_CONFIG_DIR; and set claude_dir $CLAUDE_CONFIG_DIR

    ps -e -o pid=,ppid=,args= | awk -v root=$shell_pid '
        {
            pid = $1; ppid = $2
            kind = ""
            for (i = 3; i <= 4 && i <= NF; i++) {
                n = split($i, parts, "/"); base = parts[n]
                if (base ~ /^(claude|codex|opencode)$/) { kind = base; break }
            }
            kinds[pid] = kind
            children[ppid] = children[ppid] " " pid
        }
        # Depth-first in pid order, without descending into an agent
        function walk(p,   n, list, i) {
            n = split(children[p], list, " ")
            for (i = 1; i <= n; i++) {
                if (kinds[list[i]] != "") print list[i], kinds[list[i]]
                else walk(list[i])
            }
        }
        END { if (kinds[root] != "") print root, kinds[root]; else walk(root) }' | while read -l pid kind
        # Claude registers each running process with its conversation id. A
        # conversation nobody has typed in yet has no transcript to resume.
        if test $kind = claude
            set -l session (string match -rg '"sessionId":"([^"]+)"' <$claude_dir/sessions/$pid.json 2>/dev/null)
            set -l transcript $claude_dir/projects/*/$session.jsonl
            test -n "$session"; and test (count $transcript) -gt 0
            and set kind claude:$session
        end
        echo $kind
    end
end

# One row per tmux window in this session: its first pane's folder and its agents
function __omafish_profiles_tmux_windows
    if test -z "$TMUX"
        echo "You must be inside tmux to save a profile." >&2
        return 1
    end

    set -l seen
    for win in (tmux list-windows -F '#{window_id}')
        set -l dir
        set -l agents
        for pane in (tmux list-panes -t $win -F '#{pane_pid} #{pane_current_path}')
            set -l parts (string split -m1 ' ' -- $pane)
            test -n "$dir"; or set dir $parts[2]
            set -a agents (__omafish_profiles_agents $parts[1])
        end
        contains -- $dir $seen; and continue
        set -a seen $dir
        __omafish_profiles_row $dir $agents
    end
end

# One row per tab in the current herdr workspace
function __omafish_profiles_herdr_windows
    if test -z "$HERDR_WORKSPACE_ID"
        echo "You must be inside herdr to save a profile." >&2
        return 1
    end

    set -l panes (herdr pane list | jq -r --arg ws $HERDR_WORKSPACE_ID \
        '.result.panes[] | select(.workspace_id == $ws) | [.tab_id, .pane_id, .cwd] | @tsv')
    set -l seen
    for tab in (herdr tab list | jq -r --arg ws $HERDR_WORKSPACE_ID \
            '.result.tabs | map(select(.workspace_id == $ws)) | sort_by(.number) | .[].tab_id')
        set -l dir
        set -l agents
        for pane in (string match -- "$tab	*" $panes)
            set -l parts (string split \t -- $pane)
            test -n "$dir"; or set dir $parts[3]
            set -l shell_pid (herdr pane process-info --pane $parts[2] | jq -r '.result.process_info.shell_pid')
            set -a agents (__omafish_profiles_agents $shell_pid)
        end
        contains -- $dir $seen; and continue
        set -a seen $dir
        __omafish_profiles_row $dir $agents
    end
end

# folder TAB agent kinds TAB ref1 TAB ref2
function __omafish_profiles_row
    set -l dir (string replace -r "^$HOME" '~' -- $argv[1])
    set -l refs $argv[2..3]
    set -l kinds (string replace -r ':.*' '' -- $refs | string join ', ')
    string join \t -- $dir "$kinds" $refs
end

# Usage: __omafish_profiles_tmux_open <session> <dir> <command> [<dir> <command>]...
function __omafish_profiles_tmux_open
    set -l session $argv[1]
    set -l dirs
    set -l cmds
    for i in (seq 2 2 (count $argv))
        set -a dirs $argv[$i]
        set -a cmds $argv[(math $i + 1)]
    end

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
        tmux send-keys -t "$TMUX_PANE" "cd "(string escape -- $dirs[1])"; and $cmds[1]" C-m
        for i in (seq 2 (count $dirs))
            set -l pane (tmux new-window -d -t "$session:" -c "$dirs[$i]" -P -F '#{pane_id}')
            tmux send-keys -t "$pane" "$cmds[$i]" C-m
        end
    else
        for i in (seq (count $dirs))
            set -l pane
            if tmux has-session -t "=$session" 2>/dev/null
                set pane (tmux new-window -d -t "$session:" -c "$dirs[$i]" -P -F '#{pane_id}')
            else
                set pane (tmux new-session -d -s "$session" -c "$dirs[$i]" -P -F '#{pane_id}')
            end
            tmux send-keys -t "$pane" "$cmds[$i]" C-m
        end
        tmux attach -t "=$session"
    end
end

# Usage: __omafish_profiles_herdr_open <workspace> <dir> <command> [<dir> <command>]...
function __omafish_profiles_herdr_open
    set -l label $argv[1]
    set -l dirs
    set -l cmds
    for i in (seq 2 2 (count $argv))
        set -a dirs $argv[$i]
        set -a cmds $argv[(math $i + 1)]
    end

    # Start a headless server when none is running, so the workspace is ready on attach
    if not herdr workspace list >/dev/null 2>&1
        setsid -f herdr server >/dev/null 2>&1
        for i in (seq 50)
            herdr workspace list >/dev/null 2>&1; and break
            sleep 0.1
        end
    end

    # Already open: just go there
    set -l existing (herdr workspace list | jq -r --arg l $label '.result.workspaces[] | select(.label == $l) | .workspace_id' | head -1)
    if test -n "$existing"; and test "$existing" != "$HERDR_WORKSPACE_ID"
        herdr workspace focus $existing >/dev/null
        test -n "$HERDR_PANE_ID"; or herdr
        return
    end

    set -l workspace $HERDR_WORKSPACE_ID
    set -l first 1
    if test -n "$HERDR_PANE_ID"
        # Like hdlm: take over the current workspace and reuse this tab for the first project
        herdr workspace rename $workspace $label >/dev/null
        herdr pane run $HERDR_PANE_ID "cd "(string escape -- $dirs[1])"; and $cmds[1]" >/dev/null
    else
        set -l created (herdr workspace create --cwd $dirs[1] --label $label --focus)
        set workspace (echo $created | jq -r '.result.workspace.workspace_id')
        herdr pane run (echo $created | jq -r '.result.root_pane.pane_id') $cmds[1] >/dev/null
    end

    for i in (seq 2 (count $dirs))
        set -l pane (herdr tab create --workspace $workspace --cwd $dirs[$i] --no-focus | jq -r '.result.root_pane.pane_id')
        herdr pane run $pane $cmds[$i] >/dev/null
    end

    test -n "$HERDR_PANE_ID"; or herdr
end
