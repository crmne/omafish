status is-interactive; or return

# Core
abbr -a -- g "git"
abbr -a -- gcl "git clone"

# Status
abbr -a -- gst "git status"
abbr -a -- gss "git status -s"

# Branch
abbr -a -- gb "git branch -vv"
abbr -a -- gba "git branch -a -v"
abbr -a -- "gbd!" "git branch -d"
abbr -a -- "gbD!" "git branch -D"
abbr -a -- gbm "git branch --move"

# Checkout
abbr -a -- gco "git checkout"
abbr -a -- gcom "git checkout (__omafish_git_default_branch)"
abbr -a -- gcb "git checkout -b"

# Commit
abbr -a -- gc "git commit -v"
abbr -a -- "gc!" "git commit -v --amend"
abbr -a -- "gcn!" "git commit -v --no-edit --amend"
abbr -a -- gca "git commit -v -a"
abbr -a -- "gca!" "git commit -v -a --amend"
abbr -a -- "gcan!" "git commit -v -a --no-edit --amend"
abbr -a -- gcv "git commit -v --no-verify"
abbr -a -- gcav "git commit -a -v --no-verify"
abbr -a -- "gcav!" "git commit -a -v --no-verify --amend"
abbr -a -- gcm "git commit -m"
abbr -a -- gcam "git commit -a -m"
abbr -a -- gcad "git commit -a --amend"

# Diff and log
abbr -a -- gd "git diff"
abbr -a -- gdc "git diff --cached"
abbr -a -- gl "git log"
abbr -a -- gls "git log --stat"
abbr -a -- glg "git log --oneline --decorate --color --graph"

# Pull and push
abbr -a -- gp "git pull"
abbr -a -- gup "git pull --rebase"
abbr -a -- gP "git push"
abbr -a -- "gP!" "git push --force-with-lease"
abbr -a -- gPn "git push --no-verify"
abbr -a -- "gPn!" "git push --no-verify --force-with-lease"
abbr -a -- gpu "git push origin (__omafish_git_current_branch) --set-upstream"
abbr -a -- gpa "git push origin --all"
abbr -a -- gpt "git push origin --tags"

# Rebase
abbr -a -- gr "git rebase"
abbr -a -- gra "git rebase --abort"
abbr -a -- grc "git rebase --continue"
abbr -a -- gri "git rebase --interactive"

# Stash
abbr -a -- gsta "git stash"
abbr -a -- gstp "git stash pop"
abbr -a -- gstl "git stash list"
abbr -a -- gstd "git stash drop"

# Local file ops
abbr -a -- ga "git add"
abbr -a -- gaa "git add --all"
abbr -a -- grm "git rm"
abbr -a -- grmc "git rm --cached"

# Safety-sensitive operations
abbr -a -- gclean "git clean -di"
abbr -a -- "gclean!" "git clean -dfx"
abbr -a -- "gclean!!" "git reset --hard; and git clean -dfx"
abbr -a -- gm "git merge"
abbr -a -- grf "git revert"
abbr -a -- "grp!" "git reset --hard HEAD"
