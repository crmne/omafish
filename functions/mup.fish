function mup --description 'mise up without waiting for the minimum release age'
    MISE_MINIMUM_RELEASE_AGE=0 mise up $argv
end
