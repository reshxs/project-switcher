#!/usr/bin/env zsh

# Load configuration
PROJECTS_DIR="${HOME}/Projects"
CONFIG_FILE="${HOME}/.config/project-switcher/config"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

project-switch() {
  # Handle --help flag or no arguments
  if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
    echo "project-switch - Utility for quick switching between projects"
    echo ""
    echo "Usage:"
    echo "  project-switch <project-name>        Switch to existing project"
    echo "  project-switch -py <project-name>    Switch to project and open in PyCharm"
    echo "  project-switch --new <project-name>  Create new project with git init"
    echo "  project-switch -l, --list            List all available projects"
    echo "  project-switch -h, --help            Show this help message"
    echo ""
    echo "Configuration:"
    echo "  PROJECTS_DIR: ${PROJECTS_DIR}"
    echo "  Config file:  ${CONFIG_FILE}"
    echo ""
    echo "Aliases:"
    echo "  project - shortcut for project-switch"
    return 0
  fi

  # Handle --list flag
  if [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
    echo "Available projects:"
    echo ""

    # Use eza if available, otherwise fall back to ls
    if command -v eza &>/dev/null; then
      eza --all --tree --level=1 --icons=always --no-time --no-user --group-directories-first "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
    else
      ls -1 "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
    fi

    return 0
  fi

  # Handle -py flag for opening in PyCharm
  local open_pycharm=0
  if [ "$1" = "-py" ]; then
    open_pycharm=1
    shift
  fi

  # Handle --new flag for creating new projects
  if [ "$1" = "--new" ]; then
    if [ -z "$2" ]; then
      echo "Usage: project-switch --new <project-name>"
      return 1
    fi

    local project_name="$2"
    local project_dir="${PROJECTS_DIR}/${project_name}"

    # Check if project already exists
    if [ -d "$project_dir" ]; then
      echo "Error: Project '${project_name}' already exists in ${PROJECTS_DIR}"
      return 1
    fi

    # Create new project directory
    if mkdir -p "$project_dir"; then
      cd "$project_dir" || return 1
      echo "Started new project at $(pwd)"

      # Initialize git repository
      if command -v git &>/dev/null; then
        if git init; then
          echo "Initialized git repository"
        else
          echo "Warning: Failed to initialize git repository"
        fi
      else
        echo "Warning: git is not installed, skipping repository initialization"
      fi

      # Open in PyCharm if requested
      if [ $open_pycharm -eq 1 ]; then
        if command -v pycharm &>/dev/null; then
          pycharm .
          echo "Opening project in PyCharm"
        else
          echo "Warning: pycharm command not found"
        fi
      fi
    else
      echo "Error: Failed to create project directory '${project_name}'"
      return 1
    fi

    return 0
  fi

  local project_dir="${PROJECTS_DIR}/$1"

  if [ -d "$project_dir" ]; then
    cd "$project_dir" || return 1

    # Open in PyCharm if requested
    if [ $open_pycharm -eq 1 ]; then
      if command -v pycharm &>/dev/null; then
        pycharm .
        echo "Opening project in PyCharm"
      else
        echo "Warning: pycharm command not found"
      fi
    fi
  else
    echo "Error: Project '$1' not found in ${PROJECTS_DIR}"
    echo ""
    echo "Use 'project-switch -l' to see available projects"
    return 1
  fi
}

# Zsh completion
_project_switch_complete() {
  local -a projects
  if [ -d "$PROJECTS_DIR" ]; then
    projects=(${(f)"$(ls -1 $PROJECTS_DIR 2>/dev/null)"})
    _describe 'project' projects
  fi
}

compdef _project_switch_complete project-switch

alias project="project-switch"