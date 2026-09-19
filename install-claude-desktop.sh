#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

REPO_NAME="claude-desktop"
REPO_URL="https://pkg.claude-desktop-debian.dev"
KEYRING_PATH="/usr/share/keyrings/claude-desktop.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/claude-desktop.list"

info() { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn() { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error() { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage:
  bash install-claude-desktop.sh

This script installs Claude Desktop on Debian/Ubuntu using the APT
repository from aaddrick/claude-desktop-debian. It does not use snap.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$(id -u)" -eq 0 ]]; then
  error "Run this script as a regular user; it will use sudo for privileged steps."
fi

if ! command -v apt >/dev/null 2>&1; then
  error "This installer only supports Debian/Ubuntu systems with apt."
fi

case "$(dpkg --print-architecture)" in
  amd64|arm64) ;;
  *)
    error "Unsupported architecture: $(dpkg --print-architecture). The repository documents amd64 and arm64 only."
    ;;
esac

ensure_dependencies() {
  info "Installing repository prerequisites..."
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
}

install_keyring() {
  info "Installing repository key..."
  curl -fsSL "${REPO_URL}/KEY.gpg" | sudo gpg --dearmor -o "${KEYRING_PATH}"
  sudo chmod 0644 "${KEYRING_PATH}"
}

configure_repo() {
  info "Configuring APT source list..."
  echo "deb [signed-by=${KEYRING_PATH} arch=amd64,arm64] ${REPO_URL} stable main" | sudo tee "${SOURCE_LIST_PATH}" >/dev/null
}

install_package() {
  info "Updating package lists..."
  sudo apt update -y

  if dpkg -s "${REPO_NAME}" >/dev/null 2>&1; then
    warn "${REPO_NAME} is already installed. apt will upgrade it if a newer version exists."
  fi

  info "Installing Claude Desktop..."
  sudo apt install -y "${REPO_NAME}"
}

post_install_message() {
  echo
  success "Claude Desktop installation finished."
  echo
  echo "Next steps:"
  echo "  1. Launch Claude Desktop from your application menu."
  echo "  2. If this is your first install, log out and log back in if the launcher does not appear immediately."
  echo "  3. Future updates will come from regular system updates with: sudo apt upgrade"
  echo
}

main() {
  ensure_dependencies
  install_keyring
  configure_repo
  install_package
  post_install_message
}

main "$@"
