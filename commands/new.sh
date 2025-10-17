#!/usr/bin/env zsh

# ============================================================================
# Command: project new
# Creates a new project directory with git initialization
# ============================================================================

project_new() {
  local project_name="$1"
  local should_open_pycharm="$2"
  local should_open_vscode="$3"
  local should_open_claude="$4"

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
  _handle_ide_opening "$should_open_pycharm" "$should_open_vscode" "$should_open_claude"
}
