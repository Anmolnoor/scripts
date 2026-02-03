# ZSH Setup & Custom Scripts

A complete zsh environment setup with Oh My Zsh, essential plugins, Powerlevel10k theme, and custom shortcuts.

---

## Install

**One-liner install:**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Anmolnoor/scripts/main/setup.sh)"
```

**Or clone and run:**

```bash
git clone https://github.com/Anmolnoor/scripts.git ~/.scripts
~/.scripts/setup.sh
```

The setup will guide you step by step:
1. Install Oh My Zsh
2. Install plugins (autosuggestions, syntax-highlighting, etc.)
3. Install Powerlevel10k theme with preset config
4. Ask if you want utility commands
5. Ask if you want git shortcuts

---

## Update

Check for updates and pull latest changes:

```bash
update-scripts
```

Or manually:

```bash
cd ~/.scripts && git pull
```

---

## Uninstall

To completely remove everything:

```bash
~/.scripts/uninstall.sh
```

Or run directly:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Anmolnoor/scripts/main/uninstall.sh)"
```

The uninstaller will:
- Ask for feedback (help us improve!)
- Show what will be removed
- Clean your .zshrc (backup created)
- Remove Oh My Zsh, plugins, theme, and scripts

---

## Plugins

Installed automatically by the setup script:

| Plugin | Description |
|--------|-------------|
| `zsh-autosuggestions` | Fish-like autosuggestions |
| `zsh-syntax-highlighting` | Syntax highlighting for commands |
| `fast-syntax-highlighting` | Faster syntax highlighting |
| `zsh-autocomplete` | Real-time autocomplete |
| `zsh-z` | Quick directory jumping |

---

## Commands

### Utility Commands

| Command | Description |
|---------|-------------|
| `reload` | Reload .zshrc configuration |
| `editrc` | Open .zshrc in your default editor |
| `update-scripts` | Check and update scripts from git |
| `scripts-status` | Show scripts version and status |
| `chelp` | Show all utility commands |

### Git Shortcuts

| Command | Description |
|---------|-------------|
| `gs` | git status |
| `gl` | Pretty git log with graph |
| `gd` | git diff |
| `gb` | List branches |
| `gco` | git checkout |
| `gsw` | git switch |
| `gcb "name"` | Create and switch to new branch |
| `commit "msg"` | Stage all + commit with message |
| `push` | Push current branch to origin |
| `pull` | Pull current branch from origin |
| `drop` | Discard all uncommitted changes |
| `uncommit` | Undo last commit, keep changes |
| `dropcommit` | Undo last commit, discard changes |

### AI-Powered Commands

| Command | Description |
|---------|-------------|
| `sum` | Generate AI commit summary |
| `cws` | Commit with AI summary (asks for confirmation) |
| `cwsp` | Commit with AI summary + push |
| `ghelp` | Show all git shortcuts |

---

## Files

| File | Description |
|------|-------------|
| `setup.sh` | Main setup script |
| `uninstall.sh` | Complete uninstaller |
| `commands.zsh` | Utility commands (reload, update, etc.) |
| `git-shortcuts.zsh` | Git shortcut commands |
| `help.zsh` | Help command for git shortcuts |
| `completions.zsh` | Zsh auto-completions |
| `p10k.zsh` | Powerlevel10k theme preset |

---

## About

**Author:** [Anmol Noor](https://github.com/Anmolnoor)

**Built with:** [Claude](https://claude.ai) (Anthropic's AI assistant)

---

## License

MIT License - Feel free to use and modify.
