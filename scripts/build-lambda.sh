#!/bin/bash
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

LAMBDA_DIR="${LAMBDA_DIR:-lambda}"

log_info "Starting Lambda function build..."

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

# build Lambda function
log_info "Building Lambda function..."
npm run build

log_info "Verifying Lambda build artifact..."
check_file_exists "build/function.zip"

log_success "Lambda build artifact verified"
ls -lh build/function.zip

log_success "Lambda function build complete"
