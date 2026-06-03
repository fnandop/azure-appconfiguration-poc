#!/usr/bin/env bash
set -euo pipefail

: "${AZURE_CLIENT_ID:?AZURE_CLIENT_ID is required}"
: "${RESOURCE_GROUP:?RESOURCE_GROUP is required}"

environment_name="${ENVIRONMENT_NAME:-${APP_ENVIRONMENT:-dev}}"
resource_prefix="${RESOURCE_PREFIX:-}"

if [[ -n "${AZURE_SUBSCRIPTION_ID:-}" ]]; then
  az account set --subscription "${AZURE_SUBSCRIPTION_ID}"
fi

clean_tsv() {
  tr -d '\r'
}

if [[ -n "${APP_CONFIG_NAME:-}" ]]; then
  app_config_name="${APP_CONFIG_NAME}"
elif [[ -n "${resource_prefix}" ]]; then
  app_config_name="${resource_prefix}-appconfig"
else
  app_config_name="appconfiguration-poc-${environment_name}"
fi

if [[ -n "${KEY_VAULT_NAME:-}" ]]; then
  key_vault_name="${KEY_VAULT_NAME}"
elif [[ -n "${resource_prefix}" ]]; then
  key_vault_name="${resource_prefix}-keyvault"
else
  key_vault_name="keyvault-poc-${environment_name}"
fi

echo "Resolving App Configuration '${app_config_name}'."
app_config_id="$(az appconfig show \
  --name "${app_config_name}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query id \
  --output tsv | clean_tsv)"

echo "Resolving Key Vault '${key_vault_name}'."
key_vault_id="$(az keyvault show \
  --name "${key_vault_name}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query id \
  --output tsv | clean_tsv)"

echo "Resolving service principal for app registration '${AZURE_CLIENT_ID}'."
service_principal_object_id="$(az ad sp show \
  --id "${AZURE_CLIENT_ID}" \
  --query id \
  --output tsv | clean_tsv)"

grant_role() {
  local role_name="$1"
  local scope="$2"

  existing_assignment_count="$(az role assignment list \
    --assignee "${service_principal_object_id}" \
    --scope "${scope}" \
    --include-inherited \
    --query "[?roleDefinitionName=='${role_name}'] | length(@)" \
    --output tsv | clean_tsv)"

  if [[ "${existing_assignment_count}" != "0" ]]; then
    echo "'${role_name}' is already assigned at this scope."
    return
  fi

  echo "Granting '${role_name}'."
  az role assignment create \
    --assignee-object-id "${service_principal_object_id}" \
    --assignee-principal-type ServicePrincipal \
    --role "${role_name}" \
    --scope "${scope}" \
    --output json
}

echo "Key Vault scope: ${key_vault_id}"
grant_role "Key Vault Secrets Officer" "${key_vault_id}"

echo "App Configuration scope: ${app_config_id}"
grant_role "App Configuration Data Owner" "${app_config_id}"

echo "Current import workflow assignments:"
az role assignment list \
  --assignee "${service_principal_object_id}" \
  --include-inherited \
  --query "[?scope=='${key_vault_id}' || scope=='${app_config_id}'].{role:roleDefinitionName,scope:scope}" \
  --output table

echo "Import workflow role assignments completed."
