# ─────────────────────────────────────────────────────────────
# Help / Command List
# ─────────────────────────────────────────────────────────────
# Source: ~/.scripts/help.zsh

# ghelp - show all available git shortcuts
ghelp() {
  echo ""
  echo "┌──────────────────────────────────────────────────────┐"
  echo "│               📦 Git Shortcuts                       │"
  echo "├──────────────────────────────────────────────────────┤"
  echo "│  gs              Show git status                     │"
  echo "│  gsw             Switch branch                       │"
  echo "│  gcb \"name\"      Create and switch to new branch     │"
  echo "│  gco             Checkout branch or file             │"
  echo "│  gb              List branches                       │"
  echo "│  gl              Visual git log                      │"
  echo "│  gd              Show git diff                       │"
  echo "│  gaa             Stage all changes (git add .)       │"
  echo "│  commit \"msg\"    Stage all + commit with message     │"
  echo "│  push            Push current branch to origin       │"
  echo "│  pull            Pull current branch from origin     │"
  echo "│  drop            Discard all changes (asks first)    │"
  echo "│  uncommit        Undo last commit, keep changes      │"
  echo "│  dropcommit      Undo last commit, delete changes    │"
  echo "├──────────────────────────────────────────────────────┤"
  echo "│               🤖 AI-Powered                          │"
  echo "├──────────────────────────────────────────────────────┤"
  echo "│  sum             AI commit summary (staged only)     │"
  echo "│  cws             Commit staged with AI summary       │"
  echo "│  cwsp            Commit staged with AI summary + push│"
  echo "├──────────────────────────────────────────────────────┤"
  echo "│  ghelp           Show this help                      │"
  echo "│  chelp           Show utility commands (reload etc) │"
  echo "└──────────────────────────────────────────────────────┘"
  echo ""
}
