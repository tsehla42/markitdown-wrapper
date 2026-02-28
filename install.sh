#!/bin/bash

# Install script for markitdown-wrapper
# ⚠️  DO NOT RUN WITH SUDO! Run as your regular user.

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as sudo/root
if [[ $EUID -eq 0 ]]; then
    printf "%bERROR: Do not run this script as sudo or root!%b\n" "${RED}" "${NC}"
    printf "%bRun as your regular user:%b\n" "${YELLOW}" "${NC}"
    printf "  %bcd /path/to/markitdown-wrapper%b\n" "${BLUE}" "${NC}"
    printf "  %b./install.sh%b\n\n" "${BLUE}" "${NC}"
    exit 1
fi

INSTALL_PATH="${1:-$HOME/.local/bin}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

printf "%bInstalling markitdown-wrapper to %s%b\n" "${BLUE}" "${INSTALL_PATH}" "${NC}"

# Create directory if it doesn't exist
mkdir -p "$INSTALL_PATH"

# Copy script and embed the repo path so markitdown -u can find it later
sed "s|MARKITDOWN_REPO_PATH=\"\"|MARKITDOWN_REPO_PATH=\"${REPO_DIR}\"|" "${REPO_DIR}/markitdown-wrapper.sh" > "$INSTALL_PATH/markitdown"
chmod 700 "$INSTALL_PATH/markitdown"

printf "%bInstallation complete!%b\n" "${GREEN}" "${NC}"
printf "\n"
printf "You can now use: %bmarkitdown <file>%b\n" "${BLUE}" "${NC}"
printf "\n"
printf "%bMake sure %s is in your PATH:%b\n" "${YELLOW}" "${INSTALL_PATH}" "${NC}"

# Check if in PATH
if [[ ":$PATH:" == *":${INSTALL_PATH}:"* ]]; then
    printf "%b%s is already in your PATH%b\n" "${GREEN}" "${INSTALL_PATH}" "${NC}"
else
    printf "%bAdd to your shell profile (~/.bashrc, ~/.zshrc, etc.):%b\n" "${YELLOW}" "${NC}"
    printf "%bexport PATH=\"\$PATH:%s\"%b\n" "${BLUE}" "${INSTALL_PATH}" "${NC}"
fi

printf "\n"
printf "%bTest the installation:%b\n" "${YELLOW}" "${NC}"
printf "%bmarkitdown --help%b\n" "${BLUE}" "${NC}"
