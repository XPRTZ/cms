targetScope = 'subscription'

param location string = 'germanywestcentral'
param environment string = 'preview'
param imageTag string = 'latest'

var sharedValues = json(loadTextContent('shared-values.json'))
var builtinRoles = json(loadTextContent('builtin-roles.json'))
var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var defaultName = 'xprtzbv-cms'
var resourceGroupName = 'rg-${defaultName}'
var containerAppIdentityName = 'id-${defaultName}'
var keyVaultName = 'kv-${defaultName}-${environmentShort}'
var managementResourceGroup = az.resourceGroup(
  sharedValues.subscriptionIds.common,
  sharedValues.resourceGroups.management
)
var infrastructureResourceGroup = az.resourceGroup(
  sharedValues.subscriptionIds.common,
  sharedValues.resourceGroups.infrastructure
)
var rootDomain = 'xprtz.dev'
var frontDoorProfileName = 'afd-xprtzbv-websites'
var app = 'cms'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup
  name: containerAppIdentityName
}

module storage 'modules/storageaccount.bicep' = {
  name: 'Deploy-Storage-Account'
  scope: resourceGroup
  params: {
    app: 'cms'
    environmentShort: environmentShort
    blobDataContributorRoleId: builtinRoles.storageAccount.blobDataContributor
    containerAppIdentity: containerAppIdentity.properties.principalId
  }
}

module containerAppDatabase 'modules/container-app-database.bicep' = {
  scope: resourceGroup
  name: 'Deploy-Container-App-Database'
  params: {
    location: location
    keyVaultName: keyVaultName
    containerAppUserAssignedIdentityResourceId: containerAppIdentity.id
    containerAppUserAssignedIdentityClientId: containerAppIdentity.properties.clientId
    environment: environment
    app: app
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
    databaseServerName: containerAppDatabase.outputs.containerAppDatabaseServerName
    imageTag: imageTag
    environment: environment
    app: app
  }
}

module frontdoorSettings 'modules/frontdoor.bicep' = {
  scope: infrastructureResourceGroup
  name: 'Deploy-Frontdoor-Settings'
  params: {
    frontDoorOriginHost: containerAppCms.outputs.containerAppUrl
    frontDoorProfileName: frontDoorProfileName
    application: app
    rootDomain: rootDomain
    subDomain: 'cms'
  }
}

module dns 'modules/dns.bicep' = {
  scope: managementResourceGroup
  name: 'Deploy-Dns'
  params: {
    origin: frontdoorSettings.outputs.frontDoorCustomDomainHost
    rootDomain: rootDomain
    subDomain: 'cms'
    validationToken: frontdoorSettings.outputs.frontDoorCustomDomainValidationToken
  }
}

output cmsFqdn string = containerAppCms.outputs.containerAppUrl
