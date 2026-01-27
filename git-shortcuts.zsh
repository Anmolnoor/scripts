# ─────────────────────────────────────────────────────────────
# Git Shortcuts
# ─────────────────────────────────────────────────────────────
# Source: ~/.scripts/git-shortcuts.zsh

# gs - git status shortcut
alias gs="git status"

# uncommit - undo last commit but KEEP your changes (staged)
alias uncommit="git reset --soft HEAD~1"

# dropcommit - undo last commit AND discard the changes completely
alias dropcommit="git reset --hard HEAD~1"

# commit "message" - stages all changes and commits
commit() {
  if [ -z "$1" ]; then
    echo "Usage: commit \"your commit message\""
    return 1
  fi
  git add . && git commit -m "$1"
}

# push - pushes current branch to origin
push() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    echo "Error: Not in a git repository or no branch checked out"
    return 1
  fi
  git push origin "$branch"
}

# pull - pulls current branch from origin
pull() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    echo "Error: Not in a git repository or no branch checked out"
    return 1
  fi
  git pull origin "$branch"
}

# drop - stash and drop all changes (discard all uncommitted changes)
drop() {
  git stash && git stash drop
}
