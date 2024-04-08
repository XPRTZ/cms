param location string
param keyVaultName string
param containerAppUserAssignedIdentityResourceIds array

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
  }
}

var keyVaultSecretsUser = loadJsonContent('../buildin-roles.json').keyVault.secretsUser

resource keyVaultSecretUsers 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for id in containerAppUserAssignedIdentityResourceIds: {
  scope: keyVault
  name: guid(id, keyVault.id, keyVaultSecretsUser)
  properties: {
    principalId: id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUser)
  }
}]

output keyVaultName string = keyVault.name
