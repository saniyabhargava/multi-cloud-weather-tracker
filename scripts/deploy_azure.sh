#!/usr/bin/env bash
set -euo pipefail

RG_NAME=$(terraform -chdir=../infra output -raw traffic_manager_dns >/dev/null 2>&1; terraform -chdir=../infra state show azurerm_resource_group.rg | awk -F'= ' '/name =/{print $2}' | tr -d '"')
SA_NAME=$(terraform -chdir=../infra state show azurerm_storage_account.sa | awk -F'= ' '/name =/{print $2}' | tr -d '"')

echo "Enabling and uploading static website content to Azure Storage: ${SA_NAME}"
az storage blob upload-batch \
  --account-name "${SA_NAME}" \
  --auth-mode login \
  -s ../frontend/dist \
  -d '$web' \
  --overwrite

echo "Deployed to Azure Static Website."
