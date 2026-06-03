# Azure App Configuration with .NET Aspire, Key Vault, Azure Container Apps, Spring Boot, and Node.js

This PoC demonstrates a cloud-native configuration-as-code approach using Azure App Configuration, Azure Key Vault, .NET Aspire, Azure Container Apps, and GitHub Actions. It shows how .NET, Spring Boot, and Node.js applications can consume the same centralized configuration model while keeping secrets isolated in Key Vault.

## Technologies

- **[Azure App Configuration](https://learn.microsoft.com/en-us/azure/azure-app-configuration/)** — Centralized, managed service for application settings and feature flags.
- **[Feature Flags](https://learn.microsoft.com/en-us/azure/azure-app-configuration/manage-feature-flags)** — Dynamically toggle features without redeploying code.
- **[Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/)** — Securely store and access secrets, keys, and certificates.

## GitHub Actions and Azure Setup

Use the dedicated [GitHub Actions Azure setup guide](docs/github-actions-setup.md) to configure Entra ID OIDC, GitHub Actions secrets and variables, and the Azure RBAC roles required by the deploy and import workflows.
