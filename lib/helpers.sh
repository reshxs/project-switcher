#!/usr/bin/env zsh

# ============================================================================
# Shared helper functions for project-switcher
# ============================================================================

_validate_project_name_provided() {
  local project_name="$1"

  if [ -z "$project_name" ]; then
    echo "Error: Project name is required"
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
    echo "Use 'project-switch --list' to see available projects"
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

_open_project_in_claude() {
  if ! command -v claude &>/dev/null; then
    echo "Warning: claude command not found"
    return 1
  fi

  claude
  echo "Opening project in Claude"
}

_handle_ide_opening() {
  local should_open_pycharm="$1"
  local should_open_vscode="$2"
  local should_open_claude="$3"

  if [ "$should_open_pycharm" -eq 1 ]; then
    _open_project_in_ide "pycharm" "PyCharm"
  fi

  if [ "$should_open_vscode" -eq 1 ]; then
    _open_project_in_ide "code" "VS Code"
  fi

  if [ "$should_open_claude" -eq 1 ]; then
    _open_project_in_claude
  fi
}
