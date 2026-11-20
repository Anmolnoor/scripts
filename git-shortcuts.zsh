# ─────────────────────────────────────────────────────────────
# Git Shortcuts
# ─────────────────────────────────────────────────────────────
# Source: ~/.scripts/git-shortcuts.zsh

# ─────────────────────────────────────────────────────────────
# Global spinner for loading indication
# Usage: start_spinner "message" / stop_spinner
# ─────────────────────────────────────────────────────────────
_spinner_pid=""

start_spinner() {
  local msg="${1:-Loading}"
  (
    while true; do
      for c in ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏; do
        printf "\r%s %s" "$c" "$msg" >&2
        sleep 0.1
      done
    done
  ) &!
  _spinner_pid=$!
}

stop_spinner() {
  [[ -n "$_spinner_pid" ]] && kill "$_spinner_pid" 2>/dev/null && wait "$_spinner_pid" 2>/dev/null
  _spinner_pid=""
  printf "\r\033[K" >&2
}

# ─────────────────────────────────────────────────────────────


# gs - git status shortcut
alias gs="git status"

# gsw - switch branch
alias gsw="git switch"

# gcb - create and switch to new branch
unalias gcb 2>/dev/null
gcb() {
  if [ -z "$1" ]; then
    echo "Usage: gcb \"branch-name\""
    return 1
  fi
  local branch="$1"
  local output
  output=$(git checkout -b "$branch" 2>&1)
  local ret=$?
  if [[ $ret -eq 0 ]]; then
    echo "✅ Created and switched to branch: $branch"
  else
    echo "❌ Failed to create branch"
    echo ""
    echo "$output"
    echo ""
  fi
  return $ret
}

# gco - checkout branch or file
alias gco="git checkout"

# gl - pretty git log
alias gl="git log --oneline --graph --decorate --all"

# gd - git diff
alias gd="git diff"

# gb - git branch
alias gb="git branch"

# gaa - git add all
alias gaa="git add ."

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
    echo "❌ Not in a git repository"
    return 1
  fi
  start_spinner "Pushing to $branch"
  local output
  output=$(git push origin "$branch" 2>&1)
  local ret=$?
  stop_spinner
  if [[ $ret -eq 0 ]]; then
    echo "✅ Pushed to $branch"
  else
    echo "❌ Push failed"
    echo ""
    echo "$output"
    echo ""
  fi
  return $ret
}

# pull - pulls current branch from origin
pull() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    echo "❌ Not in a git repository"
    return 1
  fi
  start_spinner "Pulling from $branch"
  local output
  output=$(git pull origin "$branch" 2>&1)
  local ret=$?
  stop_spinner
  if [[ $ret -eq 0 ]]; then
    echo "✅ Pulled from $branch"
  else
    echo "❌ Pull failed"
    echo ""
    echo "$output"
    echo ""
  fi
  return $ret
}

# drop - discard all uncommitted changes, untracked files included (asks first)
# (not `git stash && git stash drop`: on a clean tree that deletes your last stash)
drop() {
  echo -n "Discard ALL uncommitted changes, untracked files included? [y/N]: "
  read -r confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi
  # clean first: reset could revert an uncommitted .gitignore rule that protects a file
  git clean -fdq :/ && git reset --hard -q && echo "✅ Discarded all uncommitted changes"
}

# cnb - create new branch and switch to it
cnb() {
  if [ -z "$1" ]; then
    echo "Usage: cnb \"branch-name\""
    return 1
  fi
  local branch="$1"
  local output
  output=$(git checkout -b "$branch" 2>&1)
  local ret=$?
  if [[ $ret -eq 0 ]]; then
    echo "✅ Created and switched to branch: $branch"
  else
    echo "❌ Failed to create branch"
    echo ""
    echo "$output"
    echo ""
  fi
  return $ret
}

# sum - AI one-line commit summary of the STAGED changes (needs Claude Code CLI)
sum() {
  if ! command -v claude &>/dev/null; then
    echo "sum needs the Claude Code CLI (claude) on your PATH" >&2
    return 1
  fi

  local staged=$(git diff --cached --name-status 2>/dev/null)
  if [ -z "$staged" ]; then
    echo "Nothing staged. Stage files first (gaa stages everything)." >&2
    return 1
  fi

  start_spinner "Generating commit summary"

  # Build prompt with all context inline
  local prompt="You are in project: $(basename $(pwd)). Generate a concise one-line git commit message (max 72 chars) for ONLY these changes. Return ONLY the commit message text, nothing else. No quotes, no explanation, no markdown.

FILES:
$staged

DIFF:
$(git diff --cached | head -150)"

  # Answer from the prompt alone: no tools, no repo CLAUDE.md/hooks (--safe-mode),
  # no stdin (it would swallow piped answers to the confirm prompt), stdout only
  local result
  result=$(claude -p --safe-mode --model haiku --tools "" --no-session-persistence "$prompt" </dev/null)
  local ret=$?

  stop_spinner

  if [[ $ret -ne 0 ]] || [[ -z "$result" ]]; then
    echo "❌ Claude could not generate a summary" >&2
    echo "$result" >&2
    return 1
  fi
  result=$(echo "$result" | tail -1)

  # Clean up the result (remove quotes if present)
  result="${result//\"/}"
  result="${result//\'/}"
  result="${result//\`/}"
  
  echo "$result"
}

# cws - commit with AI-generated summary
cws() {
  local summary
  summary=$(sum)
  
  if [ $? -ne 0 ] || [ -z "$summary" ]; then
    echo "❌ No changes to commit"
    return 1
  fi
  
  echo "📝 $summary"
  echo -n "[Y/n/e]: "
  read -r confirm
  
  case "$confirm" in
    [Nn])
      echo "Cancelled."
      return 0
      ;;
    [Ee])
      echo -n "Message: "
      read -r summary
      [[ -z "$summary" ]] && echo "❌ Empty." && return 1
      ;;
  esac
  
  start_spinner "Committing"
  local output
  output=$(git commit -m "$summary" 2>&1)
  local ret=$?
  stop_spinner
  
  if [[ $ret -eq 0 ]]; then
    echo "✅ $summary"
  else
    echo "❌ Commit failed"
    echo ""
    echo "$output"
    echo ""
  fi
  return $ret
}

# cwsp - commit with AI-generated summary and push
cwsp() {
  local summary
  summary=$(sum)
  
  if [ $? -ne 0 ] || [ -z "$summary" ]; then
    echo "❌ No changes to commit"
    return 1
  fi
  
  echo "📝 $summary"
  echo -n "[Y/n/e]: "
  read -r confirm
  
  case "$confirm" in
    [Nn])
      echo "Cancelled."
      return 0
      ;;
    [Ee])
      echo -n "Message: "
      read -r summary
      [[ -z "$summary" ]] && echo "❌ Empty." && return 1
      ;;
  esac
  
  start_spinner "Committing"
  local output
  output=$(git commit -m "$summary" 2>&1)
  local ret=$?
  stop_spinner
  
  if [[ $ret -ne 0 ]]; then
    echo "❌ Commit failed"
    echo ""
    echo "$output"
    echo ""
    return 1
  fi
  
  echo "✅ $summary"
  
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  start_spinner "Pushing to $branch"
  output=$(git push origin "$branch" 2>&1)
  ret=$?
  stop_spinner
  
  if [[ $ret -eq 0 ]]; then
    echo "✅ Pushed to $branch"
  else
    echo "❌ Push failed"
    echo ""
    echo "$output"
    echo ""
  fi
  return $ret
}

# Auto-load completions
if [ -f ~/.scripts/completions.zsh ]; then
  source ~/.scripts/completions.zsh
fi
