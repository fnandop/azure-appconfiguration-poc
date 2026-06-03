@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param aca_env_outputs_azure_container_apps_environment_default_domain string

param aca_env_outputs_azure_container_apps_environment_id string

param spring_api_containerimage string

param spring_api_identity_outputs_id string

param app_environment_value string

param appconfig_outputs_appconfigendpoint string

param keyvault_outputs_vaulturi string

param spring_api_identity_outputs_clientid string

param aca_env_outputs_azure_container_registry_endpoint string

param aca_env_outputs_azure_container_registry_managed_identity_id string

resource spring_api 'Microsoft.App/containerApps@2025-07-01' = {
  name: 'spring-api'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: aca_env_outputs_azure_container_registry_endpoint
          identity: aca_env_outputs_azure_container_registry_managed_identity_id
        }
      ]
    }
    environmentId: aca_env_outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: spring_api_containerimage
          name: 'spring-api'
          env: [
            {
              name: 'APP_ENVIRONMENT'
              value: app_environment_value
            }
            {
              name: 'AZURE_APPCONFIG_ENDPOINT'
              value: appconfig_outputs_appconfigendpoint
            }
            {
              name: 'ConnectionStrings__appconfig'
              value: appconfig_outputs_appconfigendpoint
            }
            {
              name: 'ConnectionStrings__keyvault'
              value: keyvault_outputs_vaulturi
            }
            {
              name: 'KEYVAULT_URI'
              value: keyvault_outputs_vaulturi
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: spring_api_identity_outputs_clientid
            }
            {
              name: 'AZURE_TOKEN_CREDENTIALS'
              value: 'ManagedIdentityCredential'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${spring_api_identity_outputs_id}': { }
      '${aca_env_outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}