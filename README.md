# Shell Scripts & Shortcuts

Custom shell shortcuts to make life easier.

---

## Git Shortcuts

| Command | Description |
|---------|-------------|
| `gs` | Show git status |
| `gsw` | Switch branch |
| `gcb "name"` | Create and switch to new branch |
| `gco` | Checkout branch or file |
| `gb` | List branches |
| `gl` | Visual git log |
| `gd` | Show git diff |
| `gaa` | Stage all changes (git add .) |
| `commit "msg"` | Stage all + commit with message |
| `push` | Push current branch to origin |
| `pull` | Pull current branch from origin |
| `drop` | Discard all uncommitted changes |
| `uncommit` | Undo last commit, keep changes |
| `dropcommit` | Undo last commit, delete changes |

### AI-Powered Shortcuts

| Command | Description |
|---------|-------------|
| `sum` | Generate AI commit summary for current changes |
| `cws` | Commit with AI-generated summary (prompts for confirmation) |
| `cwsp` | Commit with AI-generated summary and push |
| `ghelp` | Show all available shortcuts |

---

## Usage Examples

```bash
# Check status
gs

# Commit all changes
commit "add login feature"

# Push to remote
push

# Pull latest
pull

# Oops, discard my uncommitted changes
drop

# Undo last commit but keep my work
uncommit

# Nuke last commit completely
dropcommit

# Get an AI-generated commit message for your changes
sum

# Commit with AI summary (shows message, asks Y/n/e to confirm/cancel/edit)
cws

# Commit with AI summary and push in one command
cwsp

# Forgot a command? Show all shortcuts
ghelp
```

---

## Files

| File | Purpose |
|------|---------|
| `git-shortcuts.zsh` | Git-related shortcuts |
| `help.zsh` | Help command to list all shortcuts |
| `.gitignore` | Template gitignore |

---

## Setup

All scripts are loaded via `~/.zshrc`:

```bash
source ~/.scripts/git-shortcuts.zsh
source ~/.scripts/help.zsh
```

After editing any script, reload with:

```bash
reload
```
