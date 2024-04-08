targetScope = 'subscription'

param location string = 'westeurope'
param imageTag string = 'latest'

var resourceGroupName = 'rg-xprtzbv-website'
var containerAppIdentityName = 'id-xprtzbv-website'
var frontDoorEndpointName = 'fde-xprtzbv-cms'
var logAnalyticsWorkspaceName = 'log-xprtzbv-website'
var keyVaultName = 'kv-xprtzbv-cms'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

module keyVault 'modules/key-vault.bicep' = {
  scope: resourceGroup
  name: 'Deploy-KeyVault-Cms'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityClientIds: [ containerAppIdentity.properties.clientId ]
  }
}

module containerAppCms 'modules/container-app-cms.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Cms'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    imageTag: imageTag
  }
}

module frontDoor 'modules/front-door.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Front-Door'
  params: {
    frontDoorEndpointName: frontDoorEndpointName
    originHostname: containerAppCms.outputs.containerAppUrl
  }
}
