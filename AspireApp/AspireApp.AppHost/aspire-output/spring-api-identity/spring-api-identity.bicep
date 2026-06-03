@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource spring_api_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: take('spring_api_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = spring_api_identity.id

output clientId string = spring_api_identity.properties.clientId

output principalId string = spring_api_identity.properties.principalId

output principalName string = spring_api_identity.name

output name string = spring_api_identity.name