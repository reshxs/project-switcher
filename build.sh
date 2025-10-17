#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build configuration
BUILD_DIR="build"
OUTPUT_FILE="${BUILD_DIR}/project-switcher"

echo "=== Building Project Switcher ==="
echo ""

# Create build directory
if [ ! -d "$BUILD_DIR" ]; then
  echo -e "${YELLOW}Creating build directory${NC}"
  mkdir -p "$BUILD_DIR"
fi

# Check if source files exist
if [ ! -f "project-switcher.sh" ]; then
  echo -e "${RED}Error: project-switcher.sh not found${NC}"
  exit 1
fi

if [ ! -f "lib/helpers.sh" ]; then
  echo -e "${RED}Error: lib/helpers.sh not found${NC}"
  exit 1
fi

if [ ! -f "commands/open.sh" ]; then
  echo -e "${RED}Error: commands/open.sh not found${NC}"
  exit 1
fi

if [ ! -f "commands/new.sh" ]; then
  echo -e "${RED}Error: commands/new.sh not found${NC}"
  exit 1
fi

if [ ! -f "commands/list.sh" ]; then
  echo -e "${RED}Error: commands/list.sh not found${NC}"
  exit 1
fi

echo -e "${YELLOW}Combining files into single executable${NC}"

# Start building the output file
cat > "$OUTPUT_FILE" << 'EOF'
#!/usr/bin/env zsh

# Load configuration
PROJECTS_DIR="${HOME}/Projects"
CONFIG_FILE="${HOME}/.config/project-switcher/config"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

# ============================================================================
# Helper functions (from lib/helpers.sh)
# ============================================================================

EOF

# Add helpers.sh content (skip shebang)
tail -n +2 lib/helpers.sh >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'

# ============================================================================
# Command: open (from commands/open.sh)
# ============================================================================

EOF

# Add open.sh content (skip shebang and first 7 lines of comments)
tail -n +2 commands/open.sh >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'

# ============================================================================
# Command: new (from commands/new.sh)
# ============================================================================

EOF

# Add new.sh content (skip shebang and first 7 lines of comments)
tail -n +2 commands/new.sh >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'

# ============================================================================
# Command: list (from commands/list.sh)
# ============================================================================

EOF

# Add list.sh content (skip shebang)
tail -n +2 commands/list.sh >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'

# ============================================================================
# Help command
# ============================================================================

_show_help_message() {
  echo "project-switch - Utility for quick switching between projects"
  echo ""
  echo "Usage:"
  echo "  project open <project-name>             Open existing project"
  echo "  project open -py <project-name>         Open project in PyCharm"
  echo "  project open -code <project-name>       Open project in VS Code"
  echo "  project open -claude <project-name>     Open project in Claude"
  echo "  project new <project-name>              Create new project with git init"
  echo "  project new -py <project-name>          Create and open in PyCharm"
  echo "  project new -code <project-name>        Create and open in VS Code"
  echo "  project new -claude <project-name>      Create and open in Claude"
  echo "  project list                            List all available projects"
  echo "  project --help, -h                      Show this help message"
  echo ""
  echo "Note: IDE flags can be combined, e.g., project open -py -code myproject"
  echo ""
  echo "Configuration:"
  echo "  PROJECTS_DIR: ${PROJECTS_DIR}"
  echo "  Config file:  ${CONFIG_FILE}"
  echo ""
  echo "Aliases:"
  echo "  project - shortcut for project-switch"
  echo "  pr - shortcut for project-switch"
}

# ============================================================================
# Main entry point
# ============================================================================

project-switch() {
  # Early return for help
  if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
    _show_help_message
    return 0
  fi

  # Extract command
  local command="$1"
  shift

  # Parse IDE flags
  local should_open_pycharm=0
  local should_open_vscode=0
  local should_open_claude=0

  while [[ "$1" == -* ]]; do
    case "$1" in
      -py)
        should_open_pycharm=1
        shift
        ;;
      -code)
        should_open_vscode=1
        shift
        ;;
      -claude)
        should_open_claude=1
        shift
        ;;
      *)
        echo "Error: Unknown flag '$1'"
        _show_help_message
        return 1
        ;;
    esac
  done

  # Get project name
  local project_name="$1"

  # Route to appropriate command handler
  case "$command" in
    open)
      project_open "$project_name" "$should_open_pycharm" "$should_open_vscode" "$should_open_claude"
      return $?
      ;;
    new)
      project_new "$project_name" "$should_open_pycharm" "$should_open_vscode" "$should_open_claude"
      return $?
      ;;
    list)
      project_list
      return $?
      ;;
    *)
      echo "Error: Unknown command '$command'"
      echo "Available commands: open, new, list"
      echo ""
      _show_help_message
      return 1
      ;;
  esac
}

# Zsh completion
if type compdef &>/dev/null; then
  _project_switch_complete() {
    local -a projects commands flags
    commands=('open:Open existing project' 'new:Create new project' 'list:List all projects' '--help:Show help message')
    flags=('-py:Open in PyCharm' '-code:Open in VS Code' '-claude:Open in Claude')

    if [ -d "$PROJECTS_DIR" ]; then
      projects=(${(f)"$(ls -1 $PROJECTS_DIR 2>/dev/null)"})
    fi

    # First argument - show commands
    if [ "$CURRENT" -eq 2 ]; then
      _describe 'command' commands
      return
    fi

    # Get the command (open/new)
    local cmd="${words[2]}"

    # If command is open or new
    if [[ "$cmd" == "open" || "$cmd" == "new" ]]; then
      # Check if current word starts with dash (flag)
      if [[ "${words[$CURRENT]}" == -* ]]; then
        _describe 'flags' flags
      else
        # Check if there are any non-flag words after command
        local has_project=0
        for ((i=3; i<$CURRENT; i++)); do
          if [[ "${words[$i]}" != -* ]]; then
            has_project=1
            break
          fi
        done

        # If no project name yet, offer projects
        if [ $has_project -eq 0 ]; then
          _describe 'project' projects
        fi
      fi
    fi
  }

  compdef _project_switch_complete project-switch 2>/dev/null || true
fi

alias project="project-switch"
alias pr="project-switch"
EOF

# Make executable
chmod +x "$OUTPUT_FILE"

echo -e "${GREEN}Build complete: ${OUTPUT_FILE}${NC}"
echo ""
echo "File size: $(wc -c < "$OUTPUT_FILE") bytes"
echo "Lines: $(wc -l < "$OUTPUT_FILE") lines"
echo ""
echo "To install, run: ./install.sh"
