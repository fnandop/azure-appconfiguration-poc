# GitHub Actions Azure Setup

Small step-by-step to configure GitHub Actions with Azure.

## 1. Set Up Azure OIDC

Check these values in `scripts/setup-azure-oidc.sh`:

```bash
GITHUB_ORG="fnandop"
GITHUB_REPO="azure-appconfiguration-poc"
APP_NAME="azure-appconfiguration-poc"
RESOURCE_GROUP_DEV="rg-appconfiguration-poc-dev"
RESOURCE_GROUP_PROD="rg-appconfiguration-poc-prod"
```

Run:

```bash
bash scripts/setup-azure-oidc.sh
```

Copy the printed values:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

## 2. Add GitHub Actions Variables

Go to:

`GitHub repository` -> `Settings` -> `Secrets and variables` -> `Actions` -> `Variables`

Add:

```text
AZURE_CLIENT_ID=<value from script>
AZURE_TENANT_ID=<value from script>
AZURE_SUBSCRIPTION_ID=<value from script>
AZURE_LOCATION=eastus
AZURE_RESOURCE_GROUP=rg-appconfiguration-poc-dev
APP_CONFIG_NAME=appconfiguration-poc-dev
KEY_VAULT_NAME=keyvault-poc-dev
```

## 3. Add GitHub Actions Secret

Go to:

`GitHub repository` -> `Settings` -> `Secrets and variables` -> `Actions` -> `Secrets`

Add:

```text
EXTERNAL_API_KEY=<secret value>
```

## 4. Run Deploy Workflow

In GitHub Actions, run:

```text
Deploy Azure App Configuration PoC
```

## 5. Grant Import Roles

Run locally:

```bash
export AZURE_SUBSCRIPTION_ID="<azure-subscription-id>"
export RESOURCE_GROUP="rg-appconfiguration-poc-dev"
export ENVIRONMENT_NAME="dev"
export APP_CONFIG_NAME="appconfiguration-poc-dev"
export KEY_VAULT_NAME="keyvault-poc-dev"
export AZURE_CLIENT_ID="<github-actions-client-id>"

bash scripts/grant-import-roles.sh
```

Wait a few minutes for Azure RBAC propagation.

## 6. Run Import Workflow

In GitHub Actions, run:

```text
Import Configuration
```
