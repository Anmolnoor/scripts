# ─────────────────────────────────────────────────────────────
# AnmolNoor's Custom Commands
# ─────────────────────────────────────────────────────────────
# Source: ~/.scripts/commands.zsh
# These are utility commands for shell management

# ─────────────────────────────────────────────────────────────
# Shell Management
# ─────────────────────────────────────────────────────────────

# reload - Reload .zshrc configuration
alias reload="source ~/.zshrc && echo '✓ .zshrc reloaded'"

# editrc - Open .zshrc in default editor
alias editrc="${EDITOR:-nano} ~/.zshrc"

# ─────────────────────────────────────────────────────────────
# Scripts Update Command
# ─────────────────────────────────────────────────────────────

# update-scripts - Check and update AnmolNoor's scripts from git
update-scripts() {
  local scripts_dir="$HOME/.scripts"
  local remote_branch="main"
  
  # Check if scripts directory exists and is a git repo
  if [[ ! -d "$scripts_dir/.git" ]]; then
    echo "❌ Scripts directory is not a git repository"
    echo "   Run the setup script to install: ~/.scripts/setup.sh"
    return 1
  fi

  echo "🔍 Checking for updates..."
  
  # Fetch latest from remote
  if ! git -C "$scripts_dir" fetch origin "$remote_branch" &>/dev/null; then
    echo "❌ Failed to fetch from remote"
    return 1
  fi

  # Check if there are updates
  local local_commit=$(git -C "$scripts_dir" rev-parse HEAD)
  local remote_commit=$(git -C "$scripts_dir" rev-parse "origin/$remote_branch")

  if [[ "$local_commit" == "$remote_commit" ]]; then
    echo "✓ Scripts are up to date"
    return 0
  fi

  # Show what's new
  echo ""
  echo "📦 Updates available:"
  git -C "$scripts_dir" log --oneline HEAD..origin/$remote_branch
  echo ""

  # Ask user to confirm update
  echo -n "Would you like to update? [Y/n]: "
  read -r confirm
  confirm="${confirm:-y}"

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "⬇️  Pulling updates..."
    if git -C "$scripts_dir" pull origin "$remote_branch"; then
      echo ""
      echo "✓ Scripts updated successfully!"
      echo "→ Run 'reload' to apply changes"
    else
      echo "❌ Failed to pull updates"
      echo "   You may have local changes. Try:"
      echo "   cd ~/.scripts && git stash && git pull && git stash pop"
      return 1
    fi
  else
    echo "Skipped update."
  fi
}

# scripts-status - Show current scripts version and status
scripts-status() {
  local scripts_dir="$HOME/.scripts"
  
  if [[ ! -d "$scripts_dir/.git" ]]; then
    echo "❌ Scripts directory is not a git repository"
    return 1
  fi

  echo "📁 Scripts Directory: $scripts_dir"
  echo ""
  
  # Current commit
  echo "📌 Current Version:"
  git -C "$scripts_dir" log -1 --format="   %h - %s (%cr)"
  echo ""
  
  # Check remote status
  git -C "$scripts_dir" fetch origin main &>/dev/null
  local local_commit=$(git -C "$scripts_dir" rev-parse HEAD)
  local remote_commit=$(git -C "$scripts_dir" rev-parse origin/main 2>/dev/null)
  
  if [[ -n "$remote_commit" ]]; then
    if [[ "$local_commit" == "$remote_commit" ]]; then
      echo "✓ Up to date with origin/main"
    else
      local behind=$(git -C "$scripts_dir" rev-list --count HEAD..origin/main)
      echo "⚠️  $behind commit(s) behind origin/main"
      echo "   Run 'update-scripts' to update"
    fi
  fi
  echo ""
  
  # Show local changes if any
  local changes=$(git -C "$scripts_dir" status --porcelain)
  if [[ -n "$changes" ]]; then
    echo "📝 Local Changes:"
    echo "$changes" | sed 's/^/   /'
  fi
}

# ─────────────────────────────────────────────────────────────
# Help for commands
# ─────────────────────────────────────────────────────────────

# chelp - Show all available custom commands
chelp() {
  echo ""
  echo "┌──────────────────────────────────────────────────────┐"
  echo "│            🛠️  Custom Commands                       │"
  echo "├──────────────────────────────────────────────────────┤"
  echo "│  reload          Reload .zshrc configuration        │"
  echo "│  editrc          Open .zshrc in editor              │"
  echo "│  update-scripts  Check and update scripts from git  │"
  echo "│  scripts-status  Show scripts version and status    │"
  echo "│  chelp           Show this help                     │"
  echo "└──────────────────────────────────────────────────────┘"
  echo ""
}
