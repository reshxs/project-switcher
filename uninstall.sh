#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Installation paths
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/project-switcher"
SCRIPT_NAME="project-switcher"
ZSHRC="${HOME}/.zshrc"

echo "=== Project Switcher Uninstallation ==="
echo ""

# Remove script from bin directory
if [ -f "${BIN_DIR}/${SCRIPT_NAME}" ]; then
  echo -e "${YELLOW}Removing ${BIN_DIR}/${SCRIPT_NAME}${NC}"
  rm "${BIN_DIR}/${SCRIPT_NAME}"
else
  echo -e "${YELLOW}Script not found in ${BIN_DIR}${NC}"
fi

# Remove sourcing from .zshrc
SOURCE_LINE="source ${BIN_DIR}/${SCRIPT_NAME}"

if [ -f "$ZSHRC" ]; then
  if grep -Fq "$SOURCE_LINE" "$ZSHRC"; then
    echo -e "${YELLOW}Removing configuration from ${ZSHRC}${NC}"
    # Create a backup
    cp "$ZSHRC" "${ZSHRC}.backup"
    # Remove the source line and the comment line before it
    sed -i.tmp '/# Project Switcher/d' "$ZSHRC"
    sed -i.tmp "\|$SOURCE_LINE|d" "$ZSHRC"
    rm "${ZSHRC}.tmp"
    echo -e "${GREEN}Backup created at ${ZSHRC}.backup${NC}"
  else
    echo -e "${YELLOW}Configuration not found in ${ZSHRC}${NC}"
  fi
fi

# Ask about config removal
if [ -d "$CONFIG_DIR" ]; then
  echo ""
  read -p "Remove configuration directory ${CONFIG_DIR}? (y/N): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Removing ${CONFIG_DIR}${NC}"
    rm -rf "$CONFIG_DIR"
  else
    echo -e "${GREEN}Keeping configuration directory${NC}"
  fi
fi

echo ""
echo -e "${GREEN}=== Uninstallation Complete ===${NC}"
echo ""
echo "To complete the removal:"
echo "  Restart your terminal or run: source ${ZSHRC}"
echo ""
