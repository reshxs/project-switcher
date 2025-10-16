#!/usr/bin/env zsh

# Load configuration
PROJECTS_DIR="${HOME}/Projects"
CONFIG_FILE="${HOME}/.config/project-switcher/config"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

# ============================================================================
# Helper functions with limited responsibility
# ============================================================================

_validate_project_name_provided() {
  local project_name="$1"

  if [ -z "$project_name" ]; then
    echo "Usage: project-switch --new <project-name>"
    return 1
  fi

  return 0
}

_validate_project_not_exists() {
  local project_dir="$1"
  local project_name="$2"

  if [ -d "$project_dir" ]; then
    echo "Error: Project '${project_name}' already exists in ${PROJECTS_DIR}"
    return 1
  fi

  return 0
}

_validate_project_exists() {
  local project_dir="$1"
  local project_name="$2"

  if [ ! -d "$project_dir" ]; then
    echo "Error: Project '${project_name}' not found in ${PROJECTS_DIR}"
    echo ""
    echo "Use 'project-switch -l' to see available projects"
    return 1
  fi

  return 0
}

_initialize_git_repository() {
  if ! command -v git &>/dev/null; then
    echo "Warning: git is not installed, skipping repository initialization"
    return 0
  fi

  if git init; then
    echo "Initialized git repository"
  else
    echo "Warning: Failed to initialize git repository"
  fi
}

_open_project_in_ide() {
  local ide_command="$1"
  local ide_name="$2"

  if ! command -v "$ide_command" &>/dev/null; then
    echo "Warning: ${ide_command} command not found"
    return 1
  fi

  "$ide_command" .
  echo "Opening project in ${ide_name}"
}

_handle_ide_opening() {
  local should_open_pycharm="$1"
  local should_open_vscode="$2"

  if [ "$should_open_pycharm" -eq 1 ]; then
    _open_project_in_ide "pycharm" "PyCharm"
  fi

  if [ "$should_open_vscode" -eq 1 ]; then
    _open_project_in_ide "code" "VS Code"
  fi
}

# ============================================================================
# Command handlers with single responsibility
# ============================================================================

_show_help_message() {
  echo "project-switch - Utility for quick switching between projects"
  echo ""
  echo "Usage:"
  echo "  project-switch <project-name>         Switch to existing project"
  echo "  project-switch -py <project-name>     Switch to project and open in PyCharm"
  echo "  project-switch -code <project-name>   Switch to project and open in VS Code"
  echo "  project-switch --new <project-name>   Create new project with git init"
  echo "  project-switch -l, --list             List all available projects"
  echo "  project-switch -h, --help             Show this help message"
  echo ""
  echo "Configuration:"
  echo "  PROJECTS_DIR: ${PROJECTS_DIR}"
  echo "  Config file:  ${CONFIG_FILE}"
  echo ""
  echo "Aliases:"
  echo "  project - shortcut for project-switch"
}

_list_available_projects() {
  echo "Available projects:"
  echo ""

  if command -v eza &>/dev/null; then
    eza --all --tree --level=1 --icons=always --no-time --no-user --group-directories-first "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
  else
    ls -1 "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
  fi
}

_create_new_project() {
  local project_name="$1"
  local should_open_pycharm="$2"
  local should_open_vscode="$3"

  _validate_project_name_provided "$project_name" || return 1

  local project_dir="${PROJECTS_DIR}/${project_name}"

  _validate_project_not_exists "$project_dir" "$project_name" || return 1

  if ! mkdir -p "$project_dir"; then
    echo "Error: Failed to create project directory '${project_name}'"
    return 1
  fi

  cd "$project_dir" || return 1
  echo "Started new project at $(pwd)"

  _initialize_git_repository
  _handle_ide_opening "$should_open_pycharm" "$should_open_vscode"
}

_switch_to_existing_project() {
  local project_name="$1"
  local should_open_pycharm="$2"
  local should_open_vscode="$3"

  local project_dir="${PROJECTS_DIR}/${project_name}"

  _validate_project_exists "$project_dir" "$project_name" || return 1

  cd "$project_dir" || return 1

  _handle_ide_opening "$should_open_pycharm" "$should_open_vscode"
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

  # Early return for list
  if [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
    _list_available_projects
    return 0
  fi

  # Parse IDE flags
  local should_open_pycharm=0
  local should_open_vscode=0

  if [ "$1" = "-py" ]; then
    should_open_pycharm=1
    shift
  fi

  if [ "$1" = "-code" ]; then
    should_open_vscode=1
    shift
  fi

  # Handle project creation
  if [ "$1" = "--new" ]; then
    _create_new_project "$2" "$should_open_pycharm" "$should_open_vscode"
    return $?
  fi

  # Handle switching to existing project
  _switch_to_existing_project "$1" "$should_open_pycharm" "$should_open_vscode"
  return $?
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
alias pr="project-switch"