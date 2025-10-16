#!/usr/bin/env zsh

# Load configuration
PROJECTS_DIR="${HOME}/Projects"
CONFIG_FILE="${HOME}/.config/project-switcher/config"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

project-switch() {
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
      echo "Created new project: ${project_name}"
      cd "$project_dir" || return 1
    else
      echo "Error: Failed to create project directory '${project_name}'"
      return 1
    fi

    return 0
  fi

  # Validate input
  if [ -z "$1" ]; then
    echo "Usage: project-switch <project-name>"
    echo "       project-switch --new <project-name>"
    echo ""
    echo "Available projects:"

    # Use eza if available, otherwise fall back to ls
    if command -v eza &>/dev/null; then
      eza --all --tree --level=1 --icons=always --no-time --no-user --group-directories-first "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
    else
      ls -1 "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
    fi

    return 1
  fi

  local project_dir="${PROJECTS_DIR}/$1"

  if [ -d "$project_dir" ]; then
    cd "$project_dir" || return 1
  else
    echo "Error: Project '$1' not found in ${PROJECTS_DIR}"
    echo ""
    echo "Available projects:"

    # Use eza if available, otherwise fall back to ls
    if command -v eza &>/dev/null; then
      eza --all --tree --level=1 --icons=always --no-time --no-user --group-directories-first "$PROJECTS_DIR" 2>/dev/null
    else
      ls -1 "$PROJECTS_DIR" 2>/dev/null
    fi

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