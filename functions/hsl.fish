function hsl --description 'create herdr swarm layout and run command in each pane'
    if test (count $argv) -lt 2
        echo "Usage: hsl <pane_count> <command>"
        return 1
    end

    if test -z "$HERDR_PANE_ID"
        echo "You must start herdr to use hsl."
        return 1
    end

    set count $argv[1]
    set cmd $argv[2]
    set current_dir "$PWD"

    herdr tab rename "$HERDR_TAB_ID" (basename "$current_dir") >/dev/null

    # Tile into a grid: ceil(sqrt(count)) columns, rows spread across them
    set cols (math "ceil(sqrt($count))")

    # Even columns come from splitting the rightmost one off at 1/(n-k+1) each time,
    # which keeps the list in left-to-right order
    set columns "$HERDR_PANE_ID"
    for k in (seq 1 (math $cols - 1))
        set -a columns (__omafish_herdr_split $columns[-1] right (math -s4 "1 / ($cols - $k + 1)") "$current_dir")
    end

    # Split each column into its share of rows, again evenly and top-to-bottom
    set panes
    for index in (seq 0 (math $cols - 1))
        set col $columns[(math $index + 1)]
        set rows (math "floor($count / $cols)")
        test $index -lt (math "$count % $cols"); and set rows (math $rows + 1)
        set -a panes $col
        set last $col
        for j in (seq 1 (math $rows - 1))
            set last (__omafish_herdr_split $last down (math -s4 "1 / ($rows - $j + 1)") "$current_dir")
            set -a panes $last
        end
    end

    for pane in $panes
        herdr pane run "$pane" "$cmd" >/dev/null
    end
end
