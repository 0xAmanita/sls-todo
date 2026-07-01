#!/bin/bash
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

LAMBDA_DIR="${LAMBDA_DIR:-lambda}"

log_info "Starting Lambda functions build..."

# Check if Lambda directory exists
check_dir_exists "$LAMBDA_DIR"

cd "$LAMBDA_DIR"

# Install dependencies
log_info "Installing Lambda dependencies..."
rm -f package-lock.json && npm install

# linting
log_info "Running lint..."
run_optional_script "lint"

# type check
log_info "Type checking Lambda code..."
npx tsc --noEmit

# tests
log_info "Running tests..."
run_optional_script "test"

# build Lambda functions
log_info "Building Lambda functions..."
npm run build

log_info "Verifying Lambda build artifacts..."
check_file_exists "build/createTodo.zip"
check_file_exists "build/listTodos.zip"
check_file_exists "build/getTodo.zip"
check_file_exists "build/updateTodo.zip"
check_file_exists "build/deleteTodo.zip"

log_success "Lambda build artifacts verified:"
ls -lh build/*.zip

log_success "Lambda functions build complete"
