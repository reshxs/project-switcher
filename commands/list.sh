#!/usr/bin/env zsh

# ============================================================================
# Command: project list
# Lists all available projects in the projects directory
# ============================================================================

project_list() {
  echo "Available projects:"
  echo ""

  if command -v eza &>/dev/null; then
    eza --all --tree --level=1 --icons=always --no-time --no-user --group-directories-first "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
  else
    ls -1 "$PROJECTS_DIR" 2>/dev/null || echo "  (no projects found)"
  fi
}
