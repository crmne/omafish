function __tdp_profiles
    for f in ~/.config/tdp/*
        test -f $f; and basename $f
    end
end

complete -c tdp -f
complete -c tdp -n __fish_use_subcommand -a 'save' -d 'Save windows of this session as a profile'
complete -c tdp -n __fish_use_subcommand -a 'ls' -d 'List profiles'
complete -c tdp -n __fish_use_subcommand -a 'edit' -d 'Edit a profile'
complete -c tdp -n __fish_use_subcommand -a 'rm' -d 'Delete a profile'
complete -c tdp -n __fish_use_subcommand -a '(__tdp_profiles)' -d 'Open profile'
complete -c tdp -n '__fish_seen_subcommand_from open edit rm save; and test (count (commandline -opc)) -eq 2' -a '(__tdp_profiles)'
