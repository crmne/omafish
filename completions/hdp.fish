function __hdp_profiles
    for f in ~/.config/tdp/*
        test -f $f; and basename $f
    end
end

complete -c hdp -f
complete -c hdp -n __fish_use_subcommand -a 'save' -d 'Save tabs of this herdr workspace as a profile'
complete -c hdp -n __fish_use_subcommand -a 'ls' -d 'List profiles'
complete -c hdp -n __fish_use_subcommand -a 'edit' -d 'Edit a profile'
complete -c hdp -n __fish_use_subcommand -a 'rm' -d 'Delete a profile'
complete -c hdp -n __fish_use_subcommand -a '(__hdp_profiles)' -d 'Open profile'
complete -c hdp -n '__fish_seen_subcommand_from open edit rm save; and test (count (commandline -opc)) -eq 2' -a '(__hdp_profiles)'
