targetScope = 'subscription'

param resourceGroupName string

param location string

param principalId string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module aca_env_acr 'aca-env-acr/aca-env-acr.bicep' = {
  name: 'aca-env-acr'
  scope: rg
  params: {
    location: location
  }
}

module aca_env 'aca-env/aca-env.bicep' = {
  name: 'aca-env'
  scope: rg
  params: {
    location: location
    aca_env_acr_outputs_name: aca_env_acr.outputs.name
    userPrincipalId: principalId
  }
}

module appconfig 'appconfig/appconfig.bicep' = {
  name: 'appconfig'
  scope: rg
  params: {
    location: location
  }
}

module keyvault 'keyvault/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    location: location
  }
}

module dotnet_api_identity 'dotnet-api-identity/dotnet-api-identity.bicep' = {
  name: 'dotnet-api-identity'
  scope: rg
  params: {
    location: location
  }
}

module dotnet_api_roles_appconfig 'dotnet-api-roles-appconfig/dotnet-api-roles-appconfig.bicep' = {
  name: 'dotnet-api-roles-appconfig'
  scope: rg
  params: {
    location: location
    appconfig_outputs_name: appconfig.outputs.name
    principalId: dotnet_api_identity.outputs.principalId
  }
}

module dotnet_api_roles_keyvault 'dotnet-api-roles-keyvault/dotnet-api-roles-keyvault.bicep' = {
  name: 'dotnet-api-roles-keyvault'
  scope: rg
  params: {
    location: location
    keyvault_outputs_name: keyvault.outputs.name
    principalId: dotnet_api_identity.outputs.principalId
  }
}

module spring_api_identity 'spring-api-identity/spring-api-identity.bicep' = {
  name: 'spring-api-identity'
  scope: rg
  params: {
    location: location
  }
}

module spring_api_roles_appconfig 'spring-api-roles-appconfig/spring-api-roles-appconfig.bicep' = {
  name: 'spring-api-roles-appconfig'
  scope: rg
  params: {
    location: location
    appconfig_outputs_name: appconfig.outputs.name
    principalId: spring_api_identity.outputs.principalId
  }
}

module spring_api_roles_keyvault 'spring-api-roles-keyvault/spring-api-roles-keyvault.bicep' = {
  name: 'spring-api-roles-keyvault'
  scope: rg
  params: {
    location: location
    keyvault_outputs_name: keyvault.outputs.name
    principalId: spring_api_identity.outputs.principalId
  }
}

module node_api_identity 'node-api-identity/node-api-identity.bicep' = {
  name: 'node-api-identity'
  scope: rg
  params: {
    location: location
  }
}

module node_api_roles_appconfig 'node-api-roles-appconfig/node-api-roles-appconfig.bicep' = {
  name: 'node-api-roles-appconfig'
  scope: rg
  params: {
    location: location
    appconfig_outputs_name: appconfig.outputs.name
    principalId: node_api_identity.outputs.principalId
  }
}

module node_api_roles_keyvault 'node-api-roles-keyvault/node-api-roles-keyvault.bicep' = {
  name: 'node-api-roles-keyvault'
  scope: rg
  params: {
    location: location
    keyvault_outputs_name: keyvault.outputs.name
    principalId: node_api_identity.outputs.principalId
  }
}

output aca_env_AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN string = aca_env.outputs.AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN

output aca_env_AZURE_CONTAINER_APPS_ENVIRONMENT_ID string = aca_env.outputs.AZURE_CONTAINER_APPS_ENVIRONMENT_ID

output aca_env_AZURE_CONTAINER_REGISTRY_ENDPOINT string = aca_env.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT

output aca_env_AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = aca_env.outputs.AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID

output dotnet_api_identity_id string = dotnet_api_identity.outputs.id

output appconfig_appConfigEndpoint string = appconfig.outputs.appConfigEndpoint

output keyvault_vaultUri string = keyvault.outputs.vaultUri

output dotnet_api_identity_clientId string = dotnet_api_identity.outputs.clientId

output spring_api_identity_id string = spring_api_identity.outputs.id

output spring_api_identity_clientId string = spring_api_identity.outputs.clientId

output node_api_identity_id string = node_api_identity.outputs.id

output node_api_identity_clientId string = node_api_identity.outputs.clientId