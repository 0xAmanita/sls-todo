#!/bin/bash
set -e

# Script to clean up orphaned Terraform state from single lambda to multiple lambdas refactor
# This removes the old integration resource that no longer exists in the code

cd terraform

echo "============================================"
echo "Terraform State Cleanup"
echo "============================================"
echo ""

# Initialize Terraform
echo "[1/4] Initializing Terraform..."
terraform init -input=false
echo "Terraform initialized"
echo ""

# List current state
echo "[2/4] Current Terraform state:"
terraform state list
echo ""

# Check if the old integration exists
echo "[3/4] Checking for orphaned integration..."
if terraform state list | grep -q 'module.api_gateway.aws_apigatewayv2_integration.lambda$'; then
    echo "Found orphaned integration: module.api_gateway.aws_apigatewayv2_integration.lambda"
    echo "This resource no longer exists in code but is still in state."
    echo ""
    echo "Removing from state..."
    terraform state rm 'module.api_gateway.aws_apigatewayv2_integration.lambda'
    echo "Successfully removed orphaned integration from state"
else
    echo "No orphaned integration found. State is clean."
fi
echo ""

# Verify expected integrations exist
echo "[4/4] Verifying current integrations:"
for integration in create_todo list_todos get_todo update_todo delete_todo; do
    if terraform state list | grep -q "module.api_gateway.aws_apigatewayv2_integration.${integration}"; then
        echo "Found ${integration} integration"
    else
        echo "Warning: ${integration} integration not found in state"
    fi
done
echo ""

echo "============================================"
echo "State cleanup complete!"
echo "============================================"
