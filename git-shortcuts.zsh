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
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    while true; do
      printf "\r%s %s" "${chars:$i:1}" "$msg" >&2
      i=$(( (i + 1) % 10 ))
      sleep 0.1
    done
  ) &
  _spinner_pid=$!
  disown
}

stop_spinner() {
  [[ -n "$_spinner_pid" ]] && kill "$_spinner_pid" 2>/dev/null
  _spinner_pid=""
  printf "\r\033[K" >&2
}

# ─────────────────────────────────────────────────────────────

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
    echo "❌ Not in a git repository"
    return 1
  fi
  start_spinner "Pushing to $branch"
  git push origin "$branch" >/dev/null 2>&1
  local ret=$?
  stop_spinner
  [[ $ret -eq 0 ]] && echo "✅ Pushed to $branch" || echo "❌ Push failed"
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
  git pull origin "$branch" >/dev/null 2>&1
  local ret=$?
  stop_spinner
  [[ $ret -eq 0 ]] && echo "✅ Pulled from $branch" || echo "❌ Pull failed"
  return $ret
}

# drop - stash and drop all changes (discard all uncommitted changes)
drop() {
  git stash && git stash drop
}

# sum - get AI-generated one-line commit summary using cursor agent
sum() {
  local status_output=$(git status --porcelain 2>/dev/null)
  local diff_output=$(git diff 2>/dev/null)
  
  if [ -z "$status_output" ]; then
    echo "No changes to summarize"
    return 1
  fi
  
  start_spinner "Generating commit summary"
  
  # Build prompt with all context inline
  local prompt="You are in project: $(basename $(pwd)). Generate a concise one-line git commit message (max 72 chars) for ONLY these changes. Return ONLY the commit message text, nothing else. No quotes, no explanation, no markdown.

STATUS:
$status_output

DIFF:
$(echo "$diff_output" | head -150)"
  
  # Use cursor agent with fresh workspace context
  local result
  result=$(cursor agent --print --mode ask --workspace "$(pwd)" "$prompt" 2>/dev/null | tail -1)
  
  stop_spinner
  
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
  git add . && git commit -m "$summary" >/dev/null 2>&1
  local ret=$?
  stop_spinner
  
  [[ $ret -eq 0 ]] && echo "✅ $summary" || echo "❌ Commit failed"
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
  git add . && git commit -m "$summary" >/dev/null 2>&1
  local ret=$?
  stop_spinner
  
  if [[ $ret -ne 0 ]]; then
    echo "❌ Commit failed"
    return 1
  fi
  
  echo "✅ $summary"
  
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  start_spinner "Pushing to $branch"
  git push origin "$branch" >/dev/null 2>&1
  ret=$?
  stop_spinner
  
  [[ $ret -eq 0 ]] && echo "✅ Pushed to $branch" || echo "❌ Push failed"
  return $ret
}
