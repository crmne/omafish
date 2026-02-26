function img2png
    set img "$argv[1]"
    set extra $argv[2..-1]
    set base (string replace -r '\.[^.]*$' '' -- "$img")
    magick "$img" $extra -strip \
        -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        "$base-optimized.png"
end
