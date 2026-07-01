#!/bin/bash
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

FRONTEND_DIR="${FRONTEND_DIR:-frontend}"
TERRAFORM_DIR="${TERRAFORM_DIR:-terraform}"

log_info "Starting frontend deployment..."

# Check if frontend directory exists
check_dir_exists "$FRONTEND_DIR"

# Load Terraform outputs
if [ -f "$TERRAFORM_DIR/terraform_outputs.env" ]; then
  source "$TERRAFORM_DIR/terraform_outputs.env"
else
  log_error "Terraform outputs not found. Please run terraform-deploy.sh first."
  exit 1
fi

# Verify required variables
if [ -z "${S3_BUCKET_NAME:-}" ] || [ -z "${CLOUDFRONT_DISTRIBUTION_ID:-}" ]; then
  log_error "Required outputs missing. S3_BUCKET_NAME and CLOUDFRONT_DISTRIBUTION_ID are required."
  exit 1
fi

log_info "Deploying to S3 bucket: $S3_BUCKET_NAME"
log_info "CloudFront distribution: $CLOUDFRONT_DISTRIBUTION_ID"

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# Check if dist directory exists
if [ ! -d "dist" ]; then
  log_error "Frontend build not found. Please build the frontend first with 'npm run build'"
  exit 1
fi

# Sync files to S3
log_info "Uploading frontend files to S3..."
aws s3 sync dist/ "s3://$S3_BUCKET_NAME/" \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "index.html" \
  --exclude "*.html"

# Upload HTML files with no-cache
log_info "Uploading HTML files with no-cache headers..."
aws s3 sync dist/ "s3://$S3_BUCKET_NAME/" \
  --cache-control "public, max-age=0, must-revalidate" \
  --exclude "*" \
  --include "*.html"

log_success "Frontend files uploaded to S3"

# Create CloudFront invalidation
log_info "Creating CloudFront invalidation..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text)

log_info "Invalidation created: $INVALIDATION_ID"
log_info "Waiting for invalidation to complete..."

# Wait for invalidation (optional, can be removed for faster CI/CD)
aws cloudfront wait invalidation-completed \
  --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
  --id "$INVALIDATION_ID" || log_warning "Invalidation wait timed out, but deployment continues..."

log_success "CloudFront cache invalidated"
log_success "Frontend deployment complete!"
log_info "Frontend URL: $CLOUDFRONT_URL"
