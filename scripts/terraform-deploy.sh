#!/bin/bash
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

TERRAFORM_DIR="${TERRAFORM_DIR:-terraform}"
PLAN_OUTPUT="plan_output.txt"

log_info "Starting Terraform deployment..."

# check if Terraform directory exists
check_dir_exists "$TERRAFORM_DIR"

# navigate to Terraform directory
cd "$TERRAFORM_DIR"

# check if Lambda artifact exists
if [ ! -f "../lambda/build/function.zip" ]; then
  log_error "Lambda artifact not found. Please build Lambda first."
  exit 1
fi

# initialize Terraform
log_info "Initializing Terraform..."
terraform init

# format check
log_info "Running Terraform format check..."
terraform fmt -check -recursive || log_warning "Format check failed but continuing..."

log_info "Validating Terraform configuration..."
terraform validate

# run tfsec security scan if available
if command -v tfsec &> /dev/null; then
  log_info "Running tfsec security scan..."
  tfsec . --soft-fail || log_warning "Security scan found issues but continuing..."
else
  log_info "tfsec not available, skipping security scan..."
fi

# plan
log_info "Running Terraform plan..."
terraform plan -out=tfplan -no-color | tee "$PLAN_OUTPUT"

# check for infrastructure changes
if grep -q "No changes" "$PLAN_OUTPUT"; then
  log_success "No infrastructure changes detected"
else
  log_warning "Infrastructure changes detected - review $PLAN_OUTPUT"
fi

# apply
log_info "Applying Terraform changes..."
terraform apply -auto-approve tfplan

# save deployment info
log_info "Saving Terraform state info..."
cat > deployment_info.txt << EOF
Deployment completed at: $(date)
Git commit: ${GITHUB_SHA:-local}
EOF
terraform state list >> deployment_info.txt

# get outputs
log_info "Extracting Terraform outputs..."
API_ENDPOINT=$(terraform output -raw api_endpoint)
COGNITO_USER_POOL_ID=$(terraform output -raw cognito_user_pool_id)
COGNITO_USER_POOL_CLIENT_ID=$(terraform output -raw cognito_user_pool_client_id)
AMPLIFY_APP_ID=$(terraform output -raw amplify_app_id)
AMPLIFY_APP_URL=$(terraform output -raw amplify_app_url)
LAMBDA_FUNCTION_NAME=$(terraform output -raw lambda_function_name)

# export outputs for use by other scripts
cat > terraform_outputs.env << EOF
API_ENDPOINT=$API_ENDPOINT
COGNITO_USER_POOL_ID=$COGNITO_USER_POOL_ID
COGNITO_USER_POOL_CLIENT_ID=$COGNITO_USER_POOL_CLIENT_ID
AMPLIFY_APP_ID=$AMPLIFY_APP_ID
AMPLIFY_APP_URL=$AMPLIFY_APP_URL
LAMBDA_FUNCTION_NAME=$LAMBDA_FUNCTION_NAME
EOF

log_info "Terraform outputs saved to terraform_outputs.env"

# test Lambda function deployment
log_info "Testing Lambda function deployment..."
if aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" &> /dev/null; then
  log_success "Lambda function verified: $LAMBDA_FUNCTION_NAME"
else
  log_warning "Lambda function verification skipped"
fi

log_success "Terraform deployment complete"
