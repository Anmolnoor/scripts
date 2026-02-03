# ─────────────────────────────────────────────────────────────
# Zsh Completions for Git Shortcuts
# ─────────────────────────────────────────────────────────────
# Source: ~/.scripts/completions.zsh

# Ensure compinit is loaded
autoload -Uz compinit && compinit

# ─────────────────────────────────────────────────────────────
# Alias Completions (Map to standard git completions)
# ─────────────────────────────────────────────────────────────

# gsw -> git switch
compdef _git gsw=git-switch

# gco -> git checkout
compdef _git gco=git-checkout

# gl -> git log
compdef _git gl=git-log

# gd -> git diff
compdef _git gd=git-diff

# gb -> git branch
compdef _git gb=git-branch

# gaa -> git add
compdef _git gaa=git-add

# gs -> git status
compdef _git gs=git-status

# ─────────────────────────────────────────────────────────────
# Custom Function Completions
# ─────────────────────────────────────────────────────────────

# gcb - Create and switch to new branch
_gcb_completion() {
  _arguments \
    '1: :_guard "^-*" "New Branch Name"'
}
compdef _gcb_completion gcb

# commit - Stage all and commit
_commit_completion() {
  _arguments \
    '1: :_guard "^-*" "Commit Message"'
}
compdef _commit_completion commit

# push - Push current branch
_push_completion() {
  _arguments \
    '*: :_guard "^-*" "No arguments needed (pushes current branch)"'
}
compdef _push_completion push

# pull - Pull current branch
_pull_completion() {
  _arguments \
    '*: :_guard "^-*" "No arguments needed (pulls current branch)"'
}
compdef _pull_completion pull

# Other simple commands
_simple_completion() {
  _arguments \
    '*: :_guard "^-*" "No arguments needed"'
}
compdef _simple_completion drop
compdef _simple_completion uncommit
compdef _simple_completion dropcommit
compdef _simple_completion sum
compdef _simple_completion cws
compdef _simple_completion cwsp
compdef _simple_completion ghelp
