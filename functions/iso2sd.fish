function iso2sd
    if test (count $argv) -lt 1
        echo "Usage: iso2sd <input_file> [output_device]"
        echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
        return 1
    end

    set iso "$argv[1]"
    set drive "$argv[2]"

    if test -z "$drive"
        set available_sds (lsblk -dpno NAME | grep -E '/dev/sd')

        if test -z "$available_sds"
            echo "No SD drives found and no drive specified"
            return 1
        end

        if command -q omarchy-drive-select
            set drive (omarchy-drive-select "$available_sds")
        else if command -q fzf
            set drive (printf "%s\n" $available_sds | fzf --prompt="Select target drive > ")
        else
            echo "Available drives:"
            for i in (seq (count $available_sds))
                echo "  [$i] $available_sds[$i]"
            end

            read -P "Select drive number: " selection
            if not string match -qr '^[0-9]+$' -- "$selection"
                echo "Invalid selection"
                return 1
            end
            if test "$selection" -lt 1 -o "$selection" -gt (count $available_sds)
                echo "Invalid selection"
                return 1
            end
            set drive $available_sds[$selection]
        end

        if test -z "$drive"
            echo "No drive selected"
            return 1
        end
    end

    sudo dd bs=4M status=progress oflag=sync if="$iso" of="$drive"
    sudo eject "$drive"
end
