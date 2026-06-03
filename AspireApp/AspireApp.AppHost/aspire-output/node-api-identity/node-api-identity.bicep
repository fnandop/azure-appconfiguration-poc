@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource node_api_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: take('node_api_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = node_api_identity.id

output clientId string = node_api_identity.properties.clientId

output principalId string = node_api_identity.properties.principalId

output principalName string = node_api_identity.name

output name string = node_api_identity.name