#!/bin/bash
# ─────────────────────────────────────────────────────────────
# ZSH Setup Script by AnmolNoor
# ─────────────────────────────────────────────────────────────
# This script sets up a complete zsh environment with:
# - Oh My Zsh
# - Essential plugins
# - Powerlevel10k theme
# - Custom commands (optional)
# ─────────────────────────────────────────────────────────────

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
ARROW="→"
SKIP="○"

# Tracking what was installed vs skipped
INSTALLED=()
SKIPPED=()

# User preferences
INSTALL_UTILITY_COMMANDS="false"
INSTALL_GIT_SHORTCUTS="false"

# ─────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────

print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}          ${BLUE}ZSH Setup Script by AnmolNoor${NC}                   ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_section() {
  echo ""
  echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
}

print_success() {
  echo -e "${GREEN}${CHECK}${NC} $1"
}

print_error() {
  echo -e "${RED}${CROSS}${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}!${NC} $1"
}

print_skip() {
  echo -e "${CYAN}${SKIP}${NC} $1 (already installed)"
}

print_info() {
  echo -e "${ARROW} $1"
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-y}"
  local answer

  if [[ "$default" == "y" ]]; then
    echo -en "${prompt} [Y/n]: "
  else
    echo -en "${prompt} [y/N]: "
  fi

  read -r answer
  answer="${answer:-$default}"

  [[ "$answer" =~ ^[Yy]$ ]]
}

command_exists() {
  command -v "$1" &>/dev/null
}

# ─────────────────────────────────────────────────────────────
# Shell Detection
# ─────────────────────────────────────────────────────────────

detect_shell() {
  print_section "Detecting Shell"

  local current_shell=$(basename "$SHELL")

  if [[ "$current_shell" == "zsh" ]]; then
    print_success "Detected: zsh"
    return 0
  elif [[ "$current_shell" == "bash" ]]; then
    print_warning "Detected: bash"
    echo ""
    print_info "This script is designed for zsh."
    echo ""

    if prompt_yes_no "Would you like to switch to zsh?"; then
      if command_exists zsh; then
        print_info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        print_success "Default shell changed to zsh"
        print_warning "Please restart your terminal and run this script again."
        exit 0
      else
        print_error "zsh is not installed."
        print_info "Install zsh first:"
        echo "  - macOS: brew install zsh"
        echo "  - Ubuntu/Debian: sudo apt install zsh"
        echo "  - Fedora: sudo dnf install zsh"
        exit 1
      fi
    else
      print_error "This script requires zsh. Exiting."
      exit 1
    fi
  else
    print_error "Unknown shell: $current_shell"
    print_info "This script requires zsh."
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Scripts Repository (FIRST - needed for theme config etc.)
# ─────────────────────────────────────────────────────────────

clone_scripts_repo() {
  print_section "AnmolNoor Scripts Repository"

  local target="$HOME/.scripts"
  local repo="https://github.com/Anmolnoor/scripts.git"

  if [[ -d "$target/.git" ]]; then
    print_skip "Scripts repository"
    SKIPPED+=("Scripts repository")
    print_info "Pulling latest changes..."
    if git -C "$target" pull &>/dev/null; then
      print_success "Scripts updated to latest"
    else
      print_warning "Could not update scripts (you may have local changes)"
    fi
    return 0
  fi

  if [[ -d "$target" ]]; then
    print_warning "~/.scripts exists but is not a git repo"
    if prompt_yes_no "Backup and replace with the git repo?"; then
      mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
      print_info "Backed up to ~/.scripts.backup.*"
    else
      print_warning "Skipping scripts repo clone"
      SKIPPED+=("Scripts repository")
      return 0
    fi
  fi

  print_info "Cloning scripts repository..."
  if git clone "$repo" "$target" &>/dev/null; then
    print_success "Scripts repository cloned to ~/.scripts"
    INSTALLED+=("Scripts repository")
  else
    print_error "Failed to clone scripts repository"
    return 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Ask User Preferences
# ─────────────────────────────────────────────────────────────

ask_utility_commands() {
  # Check if already configured
  if grep -q "source ~/.scripts/commands.zsh" "$HOME/.zshrc" 2>/dev/null; then
    print_skip "Utility commands already configured"
    INSTALL_UTILITY_COMMANDS="true"
    return 0
  fi

  print_section "Utility Commands"
  echo ""
  echo "Add utility commands?"
  echo "  • reload         → reload .zshrc instantly"
  echo "  • update-scripts → check & pull script updates"
  echo "  • chelp          → show all utility commands"
  echo ""

  if prompt_yes_no "Add utility commands?"; then
    INSTALL_UTILITY_COMMANDS="true"
    print_success "Will add utility commands"
  else
    INSTALL_UTILITY_COMMANDS="false"
    print_info "Skipping utility commands"
  fi
}

ask_git_shortcuts() {
  # Check if already configured
  if grep -q "source ~/.scripts/git-shortcuts.zsh" "$HOME/.zshrc" 2>/dev/null; then
    print_skip "Git shortcuts already configured"
    INSTALL_GIT_SHORTCUTS="true"
    return 0
  fi

  print_section "Git Shortcuts"
  echo ""
  echo "Add git shortcuts by AnmolNoor?"
  echo "  • gs, gl, gd, gb      → quick git commands"
  echo "  • commit, push, pull  → simplified workflow"
  echo "  • sum, cws, cwsp      → AI-powered commits"
  echo "  • ghelp               → show all git shortcuts"
  echo ""

  if prompt_yes_no "Add git shortcuts?"; then
    INSTALL_GIT_SHORTCUTS="true"
    print_success "Will add git shortcuts"
  else
    INSTALL_GIT_SHORTCUTS="false"
    print_info "Skipping git shortcuts"
  fi
}

# ─────────────────────────────────────────────────────────────
# Oh My Zsh Installation
# ─────────────────────────────────────────────────────────────

install_oh_my_zsh() {
  print_section "Oh My Zsh"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_skip "Oh My Zsh"
    SKIPPED+=("Oh My Zsh")
    return 0
  fi

  print_info "Installing Oh My Zsh..."

  # Install Oh My Zsh (unattended, don't change shell or run zsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh installed successfully"
    INSTALLED+=("Oh My Zsh")
  else
    print_error "Failed to install Oh My Zsh"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Plugin Installation
# ─────────────────────────────────────────────────────────────

install_plugin() {
  local name="$1"
  local repo="$2"
  local target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

  if [[ -d "$target" ]]; then
    print_skip "$name"
    SKIPPED+=("Plugin: $name")
    return 0
  fi

  print_info "Installing $name..."
  if git clone --depth=1 "$repo" "$target" &>/dev/null; then
    print_success "$name installed"
    INSTALLED+=("Plugin: $name")
  else
    print_error "Failed to install $name"
    return 1
  fi
}

install_plugins() {
  print_section "Installing Plugins"

  local plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    "zsh-autocomplete|https://github.com/marlonrichert/zsh-autocomplete.git"
    "zsh-z|https://github.com/agkozak/zsh-z.git"
  )

  for plugin in "${plugins[@]}"; do
    local name="${plugin%%|*}"
    local repo="${plugin##*|}"
    install_plugin "$name" "$repo"
  done
}

# ─────────────────────────────────────────────────────────────
# Powerlevel10k Theme Installation
# ─────────────────────────────────────────────────────────────

install_powerlevel10k() {
  print_section "Installing Powerlevel10k Theme"

  local target="$HOME/powerlevel10k"

  if [[ -d "$target" ]]; then
    print_skip "Powerlevel10k theme"
    SKIPPED+=("Powerlevel10k theme")
  else
    print_info "Installing Powerlevel10k..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target" &>/dev/null; then
      print_success "Powerlevel10k installed"
      INSTALLED+=("Powerlevel10k theme")
    else
      print_error "Failed to install Powerlevel10k"
      return 1
    fi
  fi
}

# ─────────────────────────────────────────────────────────────
# Powerlevel10k Configuration (AnmolNoor's preset)
# ─────────────────────────────────────────────────────────────

configure_powerlevel10k() {
  print_section "Powerlevel10k Configuration"

  local scripts_config="$HOME/.scripts/p10k.zsh"
  local target_config="$HOME/.p10k.zsh"

  if [[ ! -f "$scripts_config" ]]; then
    print_warning "No preset p10k.zsh found in scripts repo"
    print_info "Run 'p10k configure' to create your own configuration"
    return 0
  fi

  # Check if configs are identical (already applied)
  if [[ -f "$target_config" ]]; then
    if diff -q "$scripts_config" "$target_config" &>/dev/null; then
      print_skip "Powerlevel10k preset config"
      SKIPPED+=("Powerlevel10k config")
      return 0
    fi

    echo ""
    echo "A different Powerlevel10k configuration exists."
    echo ""
    if prompt_yes_no "Replace with AnmolNoor's preset configuration?"; then
      local backup="$HOME/.p10k.zsh.backup.$(date +%Y%m%d%H%M%S)"
      cp "$target_config" "$backup"
      print_success "Backed up existing config to ${backup##*/}"
      cp "$scripts_config" "$target_config"
      print_success "Applied AnmolNoor's Powerlevel10k preset"
      INSTALLED+=("Powerlevel10k config")
    else
      print_info "Keeping existing configuration"
      SKIPPED+=("Powerlevel10k config (kept existing)")
    fi
  else
    cp "$scripts_config" "$target_config"
    print_success "Applied AnmolNoor's Powerlevel10k preset"
    INSTALLED+=("Powerlevel10k config")
  fi
}

# ─────────────────────────────────────────────────────────────
# Configure .zshrc
# ─────────────────────────────────────────────────────────────

configure_zshrc() {
  print_section "Configuring .zshrc"

  local zshrc="$HOME/.zshrc"
  local changes_made=false

  # Check what needs to be done first
  local needs_plugins=false
  local needs_p10k=false
  local needs_utility=false
  local needs_git_shortcuts=false

  # Check if plugins need updating
  if grep -q "^plugins=(" "$zshrc" 2>/dev/null; then
    if ! grep -q "zsh-autosuggestions" "$zshrc" 2>/dev/null; then
      needs_plugins=true
    fi
  fi

  # Check if Powerlevel10k needs adding
  if ! grep -q "powerlevel10k.zsh-theme" "$zshrc" 2>/dev/null; then
    needs_p10k=true
  fi

  # Check if utility commands need adding
  if [[ "$INSTALL_UTILITY_COMMANDS" == "true" ]]; then
    if ! grep -q "source ~/.scripts/commands.zsh" "$zshrc" 2>/dev/null; then
      needs_utility=true
    fi
  fi

  # Check if git shortcuts need adding
  if [[ "$INSTALL_GIT_SHORTCUTS" == "true" ]]; then
    if ! grep -q "source ~/.scripts/git-shortcuts.zsh" "$zshrc" 2>/dev/null; then
      needs_git_shortcuts=true
    fi
  fi

  # Only backup if we need to make changes
  local needs_changes=false
  [[ "$needs_plugins" == "true" || "$needs_p10k" == "true" || "$needs_utility" == "true" || "$needs_git_shortcuts" == "true" ]] && needs_changes=true

  if [[ "$needs_changes" == "true" ]] && [[ -f "$zshrc" ]]; then
    local backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    cp "$zshrc" "$backup"
    print_success "Backed up .zshrc to ${backup##*/}"
  fi

  # Update plugins if needed
  if [[ "$needs_plugins" == "true" ]]; then
    local new_plugins="plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete zsh-z)"
    sed -i.tmp "s/^plugins=(.*)/$new_plugins/" "$zshrc"
    rm -f "$zshrc.tmp"
    print_success "Updated plugins list in .zshrc"
    changes_made=true
  else
    print_skip "Plugins in .zshrc"
  fi

  # Add Powerlevel10k if needed
  if [[ "$needs_p10k" == "true" ]]; then
    echo "" >> "$zshrc"
    echo "# Powerlevel10k theme" >> "$zshrc"
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> "$zshrc"
    echo "" >> "$zshrc"
    echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> "$zshrc"
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$zshrc"
    print_success "Added Powerlevel10k to .zshrc"
    changes_made=true
  else
    print_skip "Powerlevel10k in .zshrc"
  fi

  # Add custom commands section header if needed
  if [[ "$needs_utility" == "true" ]] || [[ "$needs_git_shortcuts" == "true" ]]; then
    # Check if header already exists
    if ! grep -q "# AnmolNoor's Custom Commands" "$zshrc" 2>/dev/null; then
      echo "" >> "$zshrc"
      echo "# ─────────────────────────────────────────────────────────────" >> "$zshrc"
      echo "# AnmolNoor's Custom Commands" >> "$zshrc"
      echo "# ─────────────────────────────────────────────────────────────" >> "$zshrc"
    fi
  fi

  # Add utility commands if requested
  if [[ "$needs_utility" == "true" ]]; then
    echo "source ~/.scripts/commands.zsh" >> "$zshrc"
    print_success "Added utility commands (commands.zsh)"
    INSTALLED+=("Utility commands")
    changes_made=true
  elif [[ "$INSTALL_UTILITY_COMMANDS" == "true" ]]; then
    print_skip "Utility commands in .zshrc"
  fi

  # Add git shortcuts if requested
  if [[ "$needs_git_shortcuts" == "true" ]]; then
    echo "source ~/.scripts/git-shortcuts.zsh" >> "$zshrc"
    echo "source ~/.scripts/help.zsh" >> "$zshrc"
    print_success "Added git shortcuts (git-shortcuts.zsh)"
    INSTALLED+=("Git shortcuts")
    changes_made=true
  elif [[ "$INSTALL_GIT_SHORTCUTS" == "true" ]]; then
    print_skip "Git shortcuts in .zshrc"
  fi

  if [[ "$changes_made" == "false" ]]; then
    print_info "No changes needed - .zshrc already fully configured"
  fi
}

# ─────────────────────────────────────────────────────────────
# Verification
# ─────────────────────────────────────────────────────────────

verify_installation() {
  print_section "Verifying Installation"

  local all_good=true

  # Check Oh My Zsh
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh"
  else
    print_error "Oh My Zsh not found"
    all_good=false
  fi

  # Check plugins
  local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "fast-syntax-highlighting" "zsh-autocomplete" "zsh-z")
  for plugin in "${plugins[@]}"; do
    local plugin_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
    if [[ -d "$plugin_path" ]]; then
      print_success "Plugin: $plugin"
    else
      print_error "Plugin: $plugin not found"
      all_good=false
    fi
  done

  # Check Powerlevel10k
  if [[ -d "$HOME/powerlevel10k" ]]; then
    print_success "Powerlevel10k theme"
  else
    print_error "Powerlevel10k not found"
    all_good=false
  fi

  # Check Powerlevel10k config
  if [[ -f "$HOME/.p10k.zsh" ]]; then
    print_success "Powerlevel10k configuration (~/.p10k.zsh)"
  else
    print_warning "Powerlevel10k config not found (run 'p10k configure')"
  fi

  # Check scripts repo
  if [[ -d "$HOME/.scripts/.git" ]]; then
    print_success "Scripts repository"
  else
    print_warning "Scripts repository (not a git repo or missing)"
  fi

  # Check utility commands if installed
  if [[ "$INSTALL_UTILITY_COMMANDS" == "true" ]]; then
    if grep -q "source ~/.scripts/commands.zsh" "$HOME/.zshrc" 2>/dev/null; then
      print_success "Utility commands configured"
    else
      print_warning "Utility commands not configured in .zshrc"
    fi
  fi

  # Check git shortcuts if installed
  if [[ "$INSTALL_GIT_SHORTCUTS" == "true" ]]; then
    if grep -q "source ~/.scripts/git-shortcuts.zsh" "$HOME/.zshrc" 2>/dev/null; then
      print_success "Git shortcuts configured"
    else
      print_warning "Git shortcuts not configured in .zshrc"
    fi
  fi

  # Check .zshrc configuration
  if grep -q "zsh-autosuggestions" "$HOME/.zshrc" 2>/dev/null; then
    print_success ".zshrc plugins configured"
  else
    print_warning ".zshrc plugins may need manual configuration"
  fi

  echo ""
  if [[ "$all_good" == "true" ]]; then
    print_success "All components verified successfully!"
  else
    print_warning "Some components may need attention"
  fi
}

# ─────────────────────────────────────────────────────────────
# Print Summary
# ─────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}                    ${GREEN}Setup Complete!${NC}                       ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""

  # Show what was newly installed
  if [[ ${#INSTALLED[@]} -gt 0 ]]; then
    echo -e "${GREEN}Newly Installed:${NC}"
    for item in "${INSTALLED[@]}"; do
      echo "  ${CHECK} $item"
    done
    echo ""
  fi

  # Show what was already installed (skipped)
  if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo -e "${CYAN}Already Installed (skipped):${NC}"
    for item in "${SKIPPED[@]}"; do
      echo "  ${SKIP} $item"
    done
    echo ""
  fi

  # If nothing was installed or skipped, show generic list
  if [[ ${#INSTALLED[@]} -eq 0 ]] && [[ ${#SKIPPED[@]} -eq 0 ]]; then
    echo -e "${BLUE}Components:${NC}"
    echo "  • Oh My Zsh"
    echo "  • Plugins: git, zsh-autosuggestions, zsh-syntax-highlighting,"
    echo "             fast-syntax-highlighting, zsh-autocomplete, zsh-z"
    echo "  • Theme: Powerlevel10k (with AnmolNoor's preset config)"
    echo "  • Scripts: ~/.scripts (from github.com/Anmolnoor/scripts)"
    echo ""
  fi

  # Show available commands based on what was installed
  if [[ "$INSTALL_UTILITY_COMMANDS" == "true" ]] || [[ "$INSTALL_GIT_SHORTCUTS" == "true" ]]; then
    echo -e "${BLUE}Commands Available:${NC}"
    
    if [[ "$INSTALL_UTILITY_COMMANDS" == "true" ]]; then
      echo "  • reload         → reload .zshrc"
      echo "  • update-scripts → check for updates"
      echo "  • chelp          → show utility commands"
    fi
    
    if [[ "$INSTALL_GIT_SHORTCUTS" == "true" ]]; then
      echo "  • gs, commit, push, pull → git shortcuts"
      echo "  • sum, cws, cwsp → AI-powered commits"
      echo "  • ghelp          → show git shortcuts"
    fi
    echo ""
  fi

  echo -e "${YELLOW}Next Steps:${NC}"
  echo "  1. Restart your terminal or run: source ~/.zshrc"
  echo "  2. Run 'p10k configure' to customize your prompt (if needed)"
  if [[ "$INSTALL_UTILITY_COMMANDS" == "true" ]]; then
    echo "  3. Run 'chelp' to see utility commands"
  fi
  if [[ "$INSTALL_GIT_SHORTCUTS" == "true" ]]; then
    echo "  4. Run 'ghelp' to see git shortcuts"
  fi
  echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
  print_header

  # Check for required commands
  if ! command_exists git; then
    print_error "git is required but not installed."
    exit 1
  fi

  if ! command_exists curl; then
    print_error "curl is required but not installed."
    exit 1
  fi

  # Detect shell
  detect_shell

  # STEP 1: Clone scripts repo (needed for theme config and other files)
  clone_scripts_repo

  # STEP 2: Install Oh My Zsh
  install_oh_my_zsh

  # STEP 3: Install plugins
  install_plugins

  # STEP 4: Install Powerlevel10k
  install_powerlevel10k

  # STEP 5: Configure Powerlevel10k with preset
  configure_powerlevel10k

  # STEP 6: Ask about utility commands
  ask_utility_commands

  # STEP 7: Ask about git shortcuts
  ask_git_shortcuts

  # STEP 8: Configure .zshrc
  configure_zshrc

  # Verify installation
  verify_installation

  # Print summary
  print_summary
}

# Run main function
main "$@"
