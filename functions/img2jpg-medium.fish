function img2jpg-medium
    set img "$argv[1]"
    set extra $argv[2..-1]
    set base (string replace -r '\.[^.]*$' '' -- "$img")
    magick "$img" $extra -resize "1800x>" -quality 95 -strip "$base-medium.jpg"
end
