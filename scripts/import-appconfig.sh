#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

: "${APP_CONFIG_NAME:?APP_CONFIG_NAME is required}"
: "${ENVIRONMENT_NAME:?ENVIRONMENT_NAME is required}"

if [[ "${ENVIRONMENT_NAME}" != "dev" && "${ENVIRONMENT_NAME}" != "prod" ]]; then
  echo "ENVIRONMENT_NAME must be dev or prod" >&2
  exit 1
fi

echo "Importing common configuration into Azure App Configuration label 'common'."
az appconfig kv import \
  -n "${APP_CONFIG_NAME}" \
  --auth-mode login \
  --label common \
  -s file \
  --path "${repo_root}/config/common.json" \
  --format json \
  --yes

echo "Importing ${ENVIRONMENT_NAME} configuration into label '${ENVIRONMENT_NAME}'."
az appconfig kv import \
  -n "${APP_CONFIG_NAME}" \
  --auth-mode login \
  --label "${ENVIRONMENT_NAME}" \
  -s file \
  --path "${repo_root}/config/${ENVIRONMENT_NAME}.json" \
  --format json \
  --yes

echo "Configuration import completed."
