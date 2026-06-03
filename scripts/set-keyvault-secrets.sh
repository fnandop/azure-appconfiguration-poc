#!/usr/bin/env bash
set -euo pipefail

: "${KEY_VAULT_NAME:?KEY_VAULT_NAME is required}"
: "${EXTERNAL_API_KEY:?EXTERNAL_API_KEY is required}"

echo "Creating or updating Key Vault secret 'external-api-key'."
az keyvault secret set \
  --vault-name "${KEY_VAULT_NAME}" \
  --name external-api-key \
  --value "${EXTERNAL_API_KEY}" \
  --only-show-errors \
  --output none

echo "Key Vault secret update completed."
