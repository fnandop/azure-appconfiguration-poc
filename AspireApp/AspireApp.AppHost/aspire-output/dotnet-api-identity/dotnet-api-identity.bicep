@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource dotnet_api_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: take('dotnet_api_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = dotnet_api_identity.id

output clientId string = dotnet_api_identity.properties.clientId

output principalId string = dotnet_api_identity.properties.principalId

output principalName string = dotnet_api_identity.name

output name string = dotnet_api_identity.name