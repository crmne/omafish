function sff --description 'pick a file with ff (newest first) and scp it to a destination'
    if test (count $argv) -eq 0
        echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
        return 1
    end

    set file (find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff)
    and test -n "$file"
    and scp "$file" "$argv[1]"
end
