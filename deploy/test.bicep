targetScope = 'subscription'

param location string = 'germanywestcentral'
param environment string = 'preview'
param imageTag string = 'latest'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'
var containerAppIdentityName = 'id-${defaultName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup
}

module postgresServer 'modules/postgresql.bicep' = {
  name: 'DeployPostgresql'
  scope: resourceGroup
  params: {
    location: 'germanywestcentral'
    administratorLogin: 'cmsadmin'
    administratorLoginPassword: keyVault.getSecret('POSTGRES-ADMIN-PASSWORD')
    resourceName: 'pgsql-xprtzbv-cms'
  }
}

module containerAppCmsCi 'modules/container-app-cms-ci.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Cms-Ci'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    imageTag: imageTag
    server: postgresServer.outputs.databaseUri
  }
}
