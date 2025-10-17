#!/usr/bin/env zsh

# ============================================================================
# Command: project open
# Opens an existing project in the terminal and optionally in IDEs
# ============================================================================

project_open() {
  local project_name="$1"
  local should_open_pycharm="$2"
  local should_open_vscode="$3"
  local should_open_claude="$4"

  local project_dir="${PROJECTS_DIR}/${project_name}"

  _validate_project_exists "$project_dir" "$project_name" || return 1

  cd "$project_dir" || return 1

  _handle_ide_opening "$should_open_pycharm" "$should_open_vscode" "$should_open_claude"
}
