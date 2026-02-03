#!/bin/bash
# ─────────────────────────────────────────────────────────────
# ZSH Setup Uninstaller by AnmolNoor
# ─────────────────────────────────────────────────────────────
# This script carefully removes all components installed by setup.sh
# ─────────────────────────────────────────────────────────────

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Symbols
CHECK="✓"
CROSS="✗"
ARROW="→"

# GitHub issues link
GITHUB_ISSUES="https://github.com/Anmolnoor/scripts/issues/new"

# ─────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────

print_header() {
  echo ""
  echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║${NC}              ${YELLOW}ZSH Setup Uninstaller${NC}                       ${RED}║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
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

print_info() {
  echo -e "${ARROW} $1"
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
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

# ─────────────────────────────────────────────────────────────
# Feedback Section
# ─────────────────────────────────────────────────────────────

ask_feedback() {
  print_section "Before You Go"

  echo ""
  echo -e "${CYAN}We're sorry to see you go!${NC}"
  echo ""
  echo "Before uninstalling, we'd love to hear your feedback."
  echo "Your input helps us improve for everyone."
  echo ""
  echo -e "${BLUE}Please consider:${NC}"
  echo "  • Was something not working correctly?"
  echo "  • Is there a feature you wish we had?"
  echo "  • Any suggestions to make it better?"
  echo ""
  echo -e "${YELLOW}Create an issue on GitHub:${NC}"
  echo -e "  ${CYAN}${GITHUB_ISSUES}${NC}"
  echo ""

  # Ask if they want to open the issues page
  if prompt_yes_no "Open GitHub issues page in browser?"; then
    # Try to open browser
    if command -v open &>/dev/null; then
      open "$GITHUB_ISSUES"
    elif command -v xdg-open &>/dev/null; then
      xdg-open "$GITHUB_ISSUES"
    else
      echo ""
      print_info "Please visit: $GITHUB_ISSUES"
    fi
    echo ""
    print_info "Take your time to submit feedback..."
    echo -n "Press Enter when ready to continue..."
    read -r
  fi

  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}  WARNING: This will remove all installed components!${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  if ! prompt_yes_no "Are you sure you want to uninstall?"; then
    echo ""
    print_success "Uninstall cancelled. Nothing was removed."
    echo ""
    exit 0
  fi
}

# ─────────────────────────────────────────────────────────────
# Show What Will Be Removed
# ─────────────────────────────────────────────────────────────

show_removal_plan() {
  print_section "Components to Remove"

  echo ""
  echo "The following will be removed:"
  echo ""

  # Check what exists
  [[ -d "$HOME/.oh-my-zsh" ]] && echo "  • Oh My Zsh (~/.oh-my-zsh)"
  [[ -d "$HOME/powerlevel10k" ]] && echo "  • Powerlevel10k (~/powerlevel10k)"
  [[ -f "$HOME/.p10k.zsh" ]] && echo "  • Powerlevel10k config (~/.p10k.zsh)"
  [[ -d "$HOME/.scripts" ]] && echo "  • Scripts directory (~/.scripts)"
  
  # Check for fonts
  local fonts_dir=""
  if [[ "$OSTYPE" == "darwin"* ]]; then
    fonts_dir="$HOME/Library/Fonts"
  else
    fonts_dir="$HOME/.local/share/fonts"
  fi
  [[ -f "$fonts_dir/MesloLGS NF Regular.ttf" ]] && echo "  • MesloLGS NF fonts"

  # Check plugins
  local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "fast-syntax-highlighting" "zsh-autocomplete" "zsh-z")
  local has_plugins=false
  for plugin in "${plugins[@]}"; do
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]]; then
      has_plugins=true
      break
    fi
  done
  [[ "$has_plugins" == "true" ]] && echo "  • Custom plugins (in ~/.oh-my-zsh/custom/plugins)"

  echo ""
  echo -e "${YELLOW}Note:${NC} Your ~/.zshrc will be cleaned but not deleted."
  echo "      A backup will be created before modifications."
  echo ""

  if ! prompt_yes_no "Continue with uninstall?"; then
    echo ""
    print_success "Uninstall cancelled."
    exit 0
  fi
}

# ─────────────────────────────────────────────────────────────
# Clean .zshrc
# ─────────────────────────────────────────────────────────────

clean_zshrc() {
  print_section "Cleaning .zshrc"

  local zshrc="$HOME/.zshrc"

  if [[ ! -f "$zshrc" ]]; then
    print_warning ".zshrc not found, skipping"
    return 0
  fi

  # Backup
  local backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
  cp "$zshrc" "$backup"
  print_success "Backed up .zshrc to ${backup##*/}"

  # Remove AnmolNoor's custom commands section
  if grep -q "# AnmolNoor's Custom Commands" "$zshrc" 2>/dev/null; then
    # Remove the section header and source lines
    sed -i.tmp '/# ─.*─/d' "$zshrc"
    sed -i.tmp '/# AnmolNoor/d' "$zshrc"
    sed -i.tmp '/source ~\/.scripts\/commands.zsh/d' "$zshrc"
    sed -i.tmp '/source ~\/.scripts\/git-shortcuts.zsh/d' "$zshrc"
    sed -i.tmp '/source ~\/.scripts\/help.zsh/d' "$zshrc"
    print_success "Removed custom commands from .zshrc"
  fi

  # Remove Powerlevel10k lines
  if grep -q "powerlevel10k" "$zshrc" 2>/dev/null; then
    sed -i.tmp '/# Powerlevel10k/d' "$zshrc"
    sed -i.tmp '/powerlevel10k.zsh-theme/d' "$zshrc"
    sed -i.tmp '/p10k configure/d' "$zshrc"
    sed -i.tmp '/\.p10k\.zsh/d' "$zshrc"
    print_success "Removed Powerlevel10k from .zshrc"
  fi

  # Remove p10k instant prompt
  if grep -q "p10k-instant-prompt" "$zshrc" 2>/dev/null; then
    sed -i.tmp '/p10k-instant-prompt/d' "$zshrc"
    sed -i.tmp '/Powerlevel10k instant prompt/d' "$zshrc"
    sed -i.tmp '/Initialization code that may require/d' "$zshrc"
    sed -i.tmp '/confirmations, etc/d' "$zshrc"
    print_success "Removed p10k instant prompt from .zshrc"
  fi

  # Reset plugins to default
  if grep -q "^plugins=(" "$zshrc" 2>/dev/null; then
    sed -i.tmp 's/^plugins=(.*)$/plugins=(git)/' "$zshrc"
    print_success "Reset plugins to default (git only)"
  fi

  # Remove reload alias if standalone
  sed -i.tmp '/alias reload=/d' "$zshrc"

  # Clean up temp files
  rm -f "$zshrc.tmp"

  # Remove empty lines at end of file
  sed -i.tmp -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$zshrc" 2>/dev/null || true
  rm -f "$zshrc.tmp"

  print_success ".zshrc cleaned"
}

# ─────────────────────────────────────────────────────────────
# Remove Components
# ─────────────────────────────────────────────────────────────

remove_plugins() {
  print_section "Removing Plugins"

  local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "fast-syntax-highlighting" "zsh-autocomplete" "zsh-z")
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

  for plugin in "${plugins[@]}"; do
    local plugin_path="$custom_dir/$plugin"
    if [[ -d "$plugin_path" ]]; then
      rm -rf "$plugin_path"
      print_success "Removed $plugin"
    fi
  done
}

remove_powerlevel10k() {
  print_section "Removing Powerlevel10k"

  # Remove theme
  if [[ -d "$HOME/powerlevel10k" ]]; then
    rm -rf "$HOME/powerlevel10k"
    print_success "Removed ~/powerlevel10k"
  else
    print_info "Powerlevel10k not found, skipping"
  fi

  # Remove config
  if [[ -f "$HOME/.p10k.zsh" ]]; then
    rm -f "$HOME/.p10k.zsh"
    print_success "Removed ~/.p10k.zsh"
  fi

  # Remove cache
  if [[ -d "$HOME/.cache" ]]; then
    rm -f "$HOME/.cache/p10k-instant-prompt-"* 2>/dev/null
    rm -f "$HOME/.cache/p10k-dump-"* 2>/dev/null
    print_success "Removed p10k cache files"
  fi
}

remove_fonts() {
  print_section "Removing MesloLGS NF Fonts"

  local fonts_dir=""
  if [[ "$OSTYPE" == "darwin"* ]]; then
    fonts_dir="$HOME/Library/Fonts"
  else
    fonts_dir="$HOME/.local/share/fonts"
  fi

  local fonts_removed=0
  for font in "$fonts_dir"/MesloLGS\ NF*.ttf; do
    if [[ -f "$font" ]]; then
      rm -f "$font"
      ((fonts_removed++))
    fi
  done

  if [[ $fonts_removed -gt 0 ]]; then
    # Refresh font cache on Linux
    if [[ "$OSTYPE" != "darwin"* ]] && command -v fc-cache &>/dev/null; then
      fc-cache -f "$fonts_dir" &>/dev/null
    fi
    print_success "Removed $fonts_removed MesloLGS NF font files"
  else
    print_info "No MesloLGS NF fonts found, skipping"
  fi
}

remove_oh_my_zsh() {
  print_section "Removing Oh My Zsh"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    rm -rf "$HOME/.oh-my-zsh"
    print_success "Removed ~/.oh-my-zsh"
  else
    print_info "Oh My Zsh not found, skipping"
  fi
}

remove_scripts() {
  print_section "Removing Scripts"

  if [[ -d "$HOME/.scripts" ]]; then
    # We're running from this directory, so we need to be careful
    local scripts_dir="$HOME/.scripts"
    
    # Copy uninstall script to temp location to finish execution
    local temp_cleanup="/tmp/zsh-setup-cleanup-$$.sh"
    
    cat > "$temp_cleanup" << 'CLEANUP_EOF'
#!/bin/bash
sleep 1
rm -rf "$HOME/.scripts"
echo "✓ Removed ~/.scripts"
rm -f "$0"
CLEANUP_EOF
    
    chmod +x "$temp_cleanup"
    print_info "Scripts will be removed after uninstall completes"
  else
    print_info "Scripts directory not found, skipping"
  fi
}

# ─────────────────────────────────────────────────────────────
# Print Summary
# ─────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}               ${GREEN}Uninstall Complete!${NC}                        ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "The following have been removed:"
  echo "  • Oh My Zsh"
  echo "  • Custom plugins"
  echo "  • Powerlevel10k theme and config"
  echo "  • MesloLGS NF fonts"
  echo "  • AnmolNoor's custom commands"
  echo ""
  echo -e "${YELLOW}Next Steps:${NC}"
  echo "  1. Restart your terminal"
  echo "  2. Your shell will use default zsh settings"
  echo ""
  echo -e "${BLUE}Want to reinstall later?${NC}"
  echo "  bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Anmolnoor/scripts/main/setup.sh)\""
  echo ""
  echo -e "${CYAN}Thank you for trying AnmolNoor's ZSH Setup!${NC}"
  echo -e "Feedback: ${CYAN}${GITHUB_ISSUES}${NC}"
  echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
  print_header

  # Ask for feedback first
  ask_feedback

  # Show what will be removed
  show_removal_plan

  # Clean .zshrc first (while Oh My Zsh still exists for paths)
  clean_zshrc

  # Remove plugins
  remove_plugins

  # Remove Powerlevel10k
  remove_powerlevel10k

  # Remove fonts
  remove_fonts

  # Remove Oh My Zsh
  remove_oh_my_zsh

  # Remove scripts directory last
  print_section "Removing Scripts"
  
  if [[ -d "$HOME/.scripts" ]]; then
    rm -rf "$HOME/.scripts"
    print_success "Removed ~/.scripts"
  fi

  # Print summary
  print_summary
}

# Run main
main "$@"
