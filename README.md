# Shell Scripts & Shortcuts

Custom shell shortcuts to make life easier.

---

## Git Shortcuts

| Command | Description |
|---------|-------------|
| `gs` | Show git status |
| `commit "msg"` | Stage all + commit with message |
| `push` | Push current branch to origin |
| `pull` | Pull current branch from origin |
| `drop` | Discard all uncommitted changes |
| `uncommit` | Undo last commit, keep changes |
| `dropcommit` | Undo last commit, delete changes |

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
```

---

## Files

| File | Purpose |
|------|---------|
| `git-shortcuts.zsh` | Git-related shortcuts |
| `.gitignore` | Template gitignore |

---

## Setup

All scripts are loaded via `~/.zshrc`:

```bash
source ~/.scripts/git-shortcuts.zsh
```

After editing any script, reload with:

```bash
reload
```
