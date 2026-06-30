#!/bin/bash
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

FRONTEND_DIR="${FRONTEND_DIR:-frontend}"
TERRAFORM_DIR="${TERRAFORM_DIR:-terraform}"
AWS_REGION="${AWS_REGION:-ap-southeast-1}"

log_info "Starting frontend deployment..."

# load Terraform outputs
if [ -f "$TERRAFORM_DIR/terraform_outputs.env" ]; then
  source "$TERRAFORM_DIR/terraform_outputs.env"
else
  log_error "Terraform outputs not found. Please run terraform-deploy.sh first."
  exit 1
fi

# check if frontend directory exists
check_dir_exists "$FRONTEND_DIR"

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# install dependencies
log_info "Installing frontend dependencies..."
npm ci

log_info "Running lint..."
run_optional_script "lint"

# tests
log_info "Running tests..."
if [ -f "package.json" ] && grep -q "\"test\"" package.json; then
  npm test -- --run || log_warning "Tests failed but continuing..."
else
  log_info "No test script found, skipping..."
fi

# create environment file
log_info "Creating environment configuration..."
cat > .env << EOF
VITE_API_URL=$API_ENDPOINT
VITE_USER_POOL_ID=$COGNITO_USER_POOL_ID
VITE_USER_POOL_CLIENT_ID=$COGNITO_USER_POOL_CLIENT_ID
EOF
log_success "Environment file created with backend configuration"

# build frontend
log_info "Building frontend..."
npm run build

check_dir_exists "dist"
log_success "Frontend build verified"
ls -lh dist/

# backup current S3 content for rollback
log_info "Creating backup of current S3 content..."
BACKUP_BUCKET="${S3_BUCKET_NAME}-backup-$(date +%Y%m%d-%H%M%S)"
if aws s3 mb "s3://$BACKUP_BUCKET" --region "$AWS_REGION" 2>/dev/null; then
  aws s3 sync "s3://$S3_BUCKET_NAME/" "s3://$BACKUP_BUCKET/" || log_warning "Backup sync skipped"
  log_info "Backup created: $BACKUP_BUCKET"
else
  log_warning "Backup bucket creation skipped"
fi

# deploy to S3
log_info "Deploying to S3 bucket: $S3_BUCKET_NAME"

# upload all files except index.html with long cache
aws s3 sync dist/ "s3://$S3_BUCKET_NAME/" \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "index.html" \
  --exclude "*.map"

# upload index.html separately with no-cache for SPA routing
aws s3 cp dist/index.html "s3://$S3_BUCKET_NAME/index.html" \
  --cache-control "no-cache, no-store, must-revalidate" \
  --content-type "text/html"

log_success "Frontend deployed successfully"

# invalidate CloudFront 
log_info "Checking for CloudFront distribution..."
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Origins.Items[?DomainName=='$S3_BUCKET_NAME.s3.amazonaws.com']].Id" \
  --output text 2>/dev/null || echo "")

if [ -n "$DISTRIBUTION_ID" ]; then
  log_info "Creating CloudFront invalidation for distribution: $DISTRIBUTION_ID"
  aws cloudfront create-invalidation \
    --distribution-id "$DISTRIBUTION_ID" \
    --paths "/*"
  log_success "CloudFront cache invalidated"
else
  log_info "No CloudFront distribution found, skipping invalidation"
fi

log_success "Frontend deployment complete"

# print deployment summary
cat << EOF

Deployment Summary
Frontend URL: http://$S3_WEBSITE_ENDPOINT
API Endpoint: $API_ENDPOINT
S3 Bucket: $S3_BUCKET_NAME
Cognito User Pool: $COGNITO_USER_POOL_ID

EOF
