#!/bin/bash

log_info() {
  echo "[INFO] $1"
}

log_success() {
  echo "[SUCCESS] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

log_warning() {
  echo "[WARNING] $1"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    log_error "$1 is not installed"
    exit 1
  fi
}

check_file_exists() {
  if [ ! -f "$1" ]; then
    log_error "File not found: $1"
    exit 1
  fi
}

check_dir_exists() {
  if [ ! -d "$1" ]; then
    log_error "Directory not found: $1"
    exit 1
  fi
}

run_optional_script() {
  local script_name=$1
  local package_json=${2:-package.json}
  
  if [ -f "$package_json" ] && grep -q "\"$script_name\"" "$package_json"; then
    npm run "$script_name" || {
      log_warning "$script_name failed but continuing..."
      return 0
    }
  else
    log_info "No $script_name script found, skipping..."
  fi
}
