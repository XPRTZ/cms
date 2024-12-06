targetScope = 'subscription'

param alternateLocation string = 'germanywestcentral'
param environment string = 'preview'

var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'
var containerAppIdentityName = 'id-${defaultName}'
var logAnalyticsWorkspaceName = 'log-${defaultName}'
var storageAccountName = 'stxprtzbvcmsprvvwhglcnmk'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

module containerAppEnvironment 'modules/container-app-environment.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Environment'
  params: {
    location: alternateLocation
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}


module postgresServer 'modules/container-app-database.bicep' = {
  name: 'Deploy-Postgresql'
  scope: resourceGroup
  params: {
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    keyVaultName: keyVaultName
    location: alternateLocation
  }
}
