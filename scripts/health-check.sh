#!/bin/bash
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

TERRAFORM_DIR="${TERRAFORM_DIR:-terraform}"
MAX_RETRIES="${MAX_RETRIES:-5}"
RETRY_DELAY="${RETRY_DELAY:-10}"

log_info "Starting health checks..."

# load Terraform outputs
if [ -f "$TERRAFORM_DIR/terraform_outputs.env" ]; then
  source "$TERRAFORM_DIR/terraform_outputs.env"
else
  log_error "Terraform outputs not found. Please run terraform-deploy.sh first."
  exit 1
fi

# test frontend URL
log_info "Testing frontend at: $AMPLIFY_APP_URL"

FRONTEND_HEALTHY=false
for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$AMPLIFY_APP_URL" || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    log_success "Frontend is accessible (HTTP $HTTP_CODE)"
    FRONTEND_HEALTHY=true
    break
  else
    log_info "Attempt $i: Frontend returned HTTP $HTTP_CODE, retrying in ${RETRY_DELAY}s..."
    sleep $RETRY_DELAY
  fi
done

if [ "$FRONTEND_HEALTHY" = false ]; then
  log_warning "Frontend health check failed after $MAX_RETRIES attempts"
fi

# test API endpoint
log_info "Testing API at: $API_ENDPOINT/todos"

API_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_ENDPOINT/todos" || echo "000")
if [ "$API_CODE" = "200" ] || [ "$API_CODE" = "401" ]; then
  log_success "API is accessible (HTTP $API_CODE)"
else
  log_warning "API returned HTTP $API_CODE"
fi

# print final health status
cat << EOF

Health Check Summary
Frontend: $([ "$FRONTEND_HEALTHY" = true ] && echo "HEALTHY" || echo "UNHEALTHY")
API: $([ "$API_CODE" = "200" ] || [ "$API_CODE" = "401" ] && echo "HEALTHY" || echo "UNHEALTHY")

Frontend URL: $AMPLIFY_APP_URL
API Endpoint: $API_ENDPOINT/todos

EOF

# Exit with error if critical checks failed
if [ "$FRONTEND_HEALTHY" = false ]; then
  log_error "Health checks failed"
  exit 1
fi

log_success "All health checks passed"
