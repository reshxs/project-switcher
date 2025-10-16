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

# Source files
SCRIPT_FILE="project-switcher.sh"
CONFIG_EXAMPLE="config.example"

echo "=== Project Switcher Installation ==="
echo ""

# Check if zsh is available
if ! command -v zsh &> /dev/null; then
  echo -e "${RED}Error: zsh is not installed${NC}"
  exit 1
fi

# Check if source files exist
if [ ! -f "$SCRIPT_FILE" ]; then
  echo -e "${RED}Error: $SCRIPT_FILE not found in current directory${NC}"
  exit 1
fi

# Create bin directory if it doesn't exist
if [ ! -d "$BIN_DIR" ]; then
  echo -e "${YELLOW}Creating ${BIN_DIR}${NC}"
  mkdir -p "$BIN_DIR"
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "${YELLOW}Creating ${CONFIG_DIR}${NC}"
  mkdir -p "$CONFIG_DIR"
fi

# Copy script to bin directory
echo -e "${YELLOW}Installing script to ${BIN_DIR}/${SCRIPT_NAME}${NC}"
cp "$SCRIPT_FILE" "${BIN_DIR}/${SCRIPT_NAME}"
chmod +x "${BIN_DIR}/${SCRIPT_NAME}"

# Create config if it doesn't exist
if [ ! -f "${CONFIG_DIR}/config" ]; then
  if [ -f "$CONFIG_EXAMPLE" ]; then
    echo -e "${YELLOW}Creating config file at ${CONFIG_DIR}/config${NC}"
    cp "$CONFIG_EXAMPLE" "${CONFIG_DIR}/config"
  else
    echo -e "${YELLOW}Creating default config file${NC}"
    cat > "${CONFIG_DIR}/config" << 'EOF'
# Project Switcher Configuration
PROJECTS_DIR="${HOME}/Projects"
EOF
  fi
else
  echo -e "${GREEN}Config file already exists, skipping${NC}"
fi

# Add sourcing to .zshrc if not already present
SOURCE_LINE="source ${BIN_DIR}/${SCRIPT_NAME}"

if [ ! -f "$ZSHRC" ]; then
  echo -e "${YELLOW}Creating ${ZSHRC}${NC}"
  touch "$ZSHRC"
fi

if grep -Fxq "$SOURCE_LINE" "$ZSHRC"; then
  echo -e "${GREEN}Already configured in ${ZSHRC}${NC}"
else
  echo -e "${YELLOW}Adding source line to ${ZSHRC}${NC}"
  echo "" >> "$ZSHRC"
  echo "# Project Switcher" >> "$ZSHRC"
  echo "$SOURCE_LINE" >> "$ZSHRC"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
  echo ""
  echo -e "${YELLOW}Warning: ${BIN_DIR} is not in your PATH${NC}"
  echo "Add this line to your .zshrc:"
  echo "  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "To start using project-switcher:"
echo "  1. Restart your terminal or run: source ${ZSHRC}"
echo "  2. Use: project-switch <project-name> or project <project-name>"
echo "  3. Configure projects directory in: ${CONFIG_DIR}/config"
echo ""
