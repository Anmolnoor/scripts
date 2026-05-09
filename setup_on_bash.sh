#!/bin/bash
# ─────────────────────────────────────────────────────────────
# ZSH Bootstrap for Bash Systems by AnmolNoor
# ─────────────────────────────────────────────────────────────
# For users currently on bash who want the full zsh setup.
# This script:
#   1. Installs zsh via the system package manager
#   2. Sets zsh as the default login shell (chsh)
#   3. Hands off to setup.sh to install Oh My Zsh, plugins,
#      Powerlevel10k, fonts, and AnmolNoor's custom commands
#
# Run with:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/Anmolnoor/scripts/main/setup_on_bash.sh)"
# ─────────────────────────────────────────────────────────────

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CHECK="✓"
CROSS="✗"
ARROW="→"

print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}     ${BLUE}ZSH Bootstrap for Bash Systems by AnmolNoor${NC}        ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_section() {
  echo ""
  echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}─────────────────────────────────────────────────────────────${NC}"
}

print_success() { echo -e "${GREEN}${CHECK}${NC} $1"; }
print_error()   { echo -e "${RED}${CROSS}${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_info()    { echo -e "${ARROW} $1"; }

command_exists() {
  command -v "$1" &>/dev/null
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

# ─────────────────────────────────────────────────────────────
# Detect package manager and install zsh
# ─────────────────────────────────────────────────────────────

install_zsh() {
  print_section "Installing zsh"

  if command_exists zsh; then
    print_success "zsh is already installed ($(zsh --version | head -1))"
    return 0
  fi

  print_info "zsh not found. Detecting package manager..."

  local sudo_cmd=""
  if [[ $EUID -ne 0 ]] && command_exists sudo; then
    sudo_cmd="sudo"
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command_exists brew; then
      print_info "Using Homebrew"
      brew install zsh
    else
      print_error "Homebrew not found. Install from https://brew.sh first."
      exit 1
    fi
  elif command_exists apt-get; then
    print_info "Using apt-get (Debian/Ubuntu)"
    $sudo_cmd apt-get update
    $sudo_cmd apt-get install -y zsh
  elif command_exists dnf; then
    print_info "Using dnf (Fedora/RHEL)"
    $sudo_cmd dnf install -y zsh
  elif command_exists yum; then
    print_info "Using yum (older RHEL/CentOS)"
    $sudo_cmd yum install -y zsh
  elif command_exists pacman; then
    print_info "Using pacman (Arch)"
    $sudo_cmd pacman -S --noconfirm zsh
  elif command_exists zypper; then
    print_info "Using zypper (openSUSE)"
    $sudo_cmd zypper install -y zsh
  elif command_exists apk; then
    print_info "Using apk (Alpine)"
    $sudo_cmd apk add zsh
  else
    print_error "No supported package manager found."
    print_info "Please install zsh manually, then run setup.sh."
    exit 1
  fi

  if command_exists zsh; then
    print_success "zsh installed: $(which zsh)"
  else
    print_error "zsh installation appears to have failed."
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# Register zsh in /etc/shells if missing
# ─────────────────────────────────────────────────────────────

register_zsh_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ -z "$zsh_path" ]]; then
    return 1
  fi

  if grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    return 0
  fi

  print_info "Adding $zsh_path to /etc/shells"
  local sudo_cmd=""
  if [[ $EUID -ne 0 ]] && command_exists sudo; then
    sudo_cmd="sudo"
  fi
  echo "$zsh_path" | $sudo_cmd tee -a /etc/shells >/dev/null || \
    print_warning "Could not modify /etc/shells (chsh may complain)"
}

# ─────────────────────────────────────────────────────────────
# Set zsh as default shell
# ─────────────────────────────────────────────────────────────

set_default_shell() {
  print_section "Setting zsh as Default Shell"

  local zsh_path
  zsh_path="$(command -v zsh)"
  local current_shell
  current_shell="$(basename "${SHELL:-bash}")"

  if [[ "$SHELL" == "$zsh_path" ]] || [[ "$current_shell" == "zsh" ]]; then
    print_success "zsh is already your default shell"
    return 0
  fi

  register_zsh_shell

  if ! prompt_yes_no "Change your default shell to zsh ($zsh_path)?"; then
    print_warning "Skipping default-shell change. You can run 'chsh -s $zsh_path' later."
    return 0
  fi

  if chsh -s "$zsh_path"; then
    print_success "Default shell changed to zsh"
    print_info "The change applies to new login sessions."
  else
    print_warning "chsh failed. You may need to run it manually:"
    echo "    chsh -s $zsh_path"
  fi
}

# ─────────────────────────────────────────────────────────────
# Run setup.sh under zsh-aware environment
# ─────────────────────────────────────────────────────────────

run_zsh_setup() {
  print_section "Running setup.sh"

  local zsh_path
  zsh_path="$(command -v zsh)"
  local repo="https://github.com/Anmolnoor/scripts.git"
  local target="$HOME/.scripts"
  local setup_script="$target/setup.sh"

  # Get the scripts repo first so we have a local setup.sh to invoke
  if [[ -d "$target/.git" ]]; then
    print_info "Updating existing ~/.scripts"
    git -C "$target" pull --ff-only origin main &>/dev/null || \
      print_warning "Could not fast-forward ~/.scripts (continuing)"
  elif [[ -d "$target" ]]; then
    print_warning "~/.scripts exists but is not a git repo. Backing up."
    mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
    git clone "$repo" "$target"
  else
    print_info "Cloning scripts repository to ~/.scripts"
    git clone "$repo" "$target"
  fi

  if [[ ! -f "$setup_script" ]]; then
    print_error "setup.sh not found at $setup_script"
    exit 1
  fi

  chmod +x "$setup_script"

  # setup.sh inspects $SHELL — override it for this child process so its
  # zsh-only check passes even though we're still running under bash.
  print_info "Handing off to setup.sh (SHELL overridden to $zsh_path)"
  echo ""

  # Disable set -e around the child invocation so we can capture its exit
  # code and surface a clear error instead of silently aborting.
  set +e
  SHELL="$zsh_path" bash "$setup_script"
  local rc=$?
  set -e

  if [[ $rc -ne 0 ]]; then
    echo ""
    print_error "setup.sh exited with code $rc — installation is incomplete."
    print_info "Inspect the output above for the failure point. Common causes:"
    echo "    • Network failure during a git clone or curl"
    echo "    • Missing system dependency"
    echo "    • Interrupted prompt"
    print_info "Once resolved, re-run:"
    echo "    SHELL=$zsh_path bash ~/.scripts/setup.sh"
    exit "$rc"
  fi
}

# ─────────────────────────────────────────────────────────────
# Final notes
# ─────────────────────────────────────────────────────────────

print_final_notes() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}             ${GREEN}Bootstrap Complete!${NC}                          ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${YELLOW}One last step:${NC}"
  echo "  Log out and back in (or open a new terminal) so your"
  echo "  default shell becomes zsh. Then enjoy:"
  echo ""
  echo "    chelp   → utility commands"
  echo "    ghelp   → git shortcuts"
  echo ""
  echo "  If your terminal still opens in bash, run:  exec zsh"
  echo ""
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
  print_header

  if ! command_exists git; then
    print_error "git is required but not installed."
    exit 1
  fi

  if ! command_exists curl; then
    print_error "curl is required but not installed."
    exit 1
  fi

  install_zsh
  set_default_shell
  run_zsh_setup
  print_final_notes
}

main "$@"
