function gabbr --description "Show omafish git abbreviations"
    printf "\033[1mabbr\t\tcommand\033[0m\n"
    set -l tab (printf '\t')
    set -l rows

    for line in (abbr --show)
        if string match -q -r '^abbr -a -- g' -- $line
            set -l clean (string replace -r '^abbr -a -- ' '' -- $line)
            set -l cols (string split -m 1 ' ' -- $clean)
            set -l name $cols[1]
            set -l cmd $cols[2]
            set -l display
            set cmd (string replace -r "^'(.*)'\$" '$1' -- $cmd)

            if test "$name" = "gclean!!"
                set display (printf "%s\t%s" "$name" "$cmd")
            else
                set display (printf "%s\t\t%s" "$name" "$cmd")
            end

            set rows $rows (printf "%s\t%s" "$cmd" "$display")
        end
    end

    for row in (printf "%s\n" $rows | sort)
        set -l parts (string split -m 1 $tab -- $row)
        echo $parts[2]
    end
end
