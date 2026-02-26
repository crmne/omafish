function img2jpg
    set img "$argv[1]"
    set extra $argv[2..-1]
    set base (string replace -r '\.[^.]*$' '' -- "$img")
    magick "$img" $extra -quality 95 -strip "$base-converted.jpg"
end
