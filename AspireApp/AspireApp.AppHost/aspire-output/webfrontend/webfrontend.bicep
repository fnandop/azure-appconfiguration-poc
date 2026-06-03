@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param aca_env_outputs_azure_container_apps_environment_default_domain string

param aca_env_outputs_azure_container_apps_environment_id string

param webfrontend_containerimage string

param webfrontend_containerport string

param aca_env_outputs_azure_container_registry_endpoint string

param aca_env_outputs_azure_container_registry_managed_identity_id string

resource webfrontend 'Microsoft.App/containerApps@2025-10-02-preview' = {
  name: 'webfrontend'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: int(webfrontend_containerport)
        transport: 'http'
      }
      registries: [
        {
          server: aca_env_outputs_azure_container_registry_endpoint
          identity: aca_env_outputs_azure_container_registry_managed_identity_id
        }
      ]
      runtime: {
        dotnet: {
          autoConfigureDataProtection: true
        }
      }
    }
    environmentId: aca_env_outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: webfrontend_containerimage
          name: 'webfrontend'
          env: [
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_RETRY'
              value: 'in_memory'
            }
            {
              name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
              value: 'true'
            }
            {
              name: 'HTTP_PORTS'
              value: webfrontend_containerport
            }
            {
              name: 'DOTNET_API_HTTP'
              value: 'https://dotnet-api.${aca_env_outputs_azure_container_apps_environment_default_domain}'
            }
            {
              name: 'services__dotnet-api__http__0'
              value: 'https://dotnet-api.${aca_env_outputs_azure_container_apps_environment_default_domain}'
            }
            {
              name: 'DOTNET_API_HTTPS'
              value: 'https://dotnet-api.${aca_env_outputs_azure_container_apps_environment_default_domain}'
            }
            {
              name: 'services__dotnet-api__https__0'
              value: 'https://dotnet-api.${aca_env_outputs_azure_container_apps_environment_default_domain}'
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
      '${aca_env_outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}