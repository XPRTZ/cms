@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param sku string = 'Standard_LRS'
param app string
param location string = 'germanywestcentral'
param environmentShort string = 'preview'

var name = take('stxprtzbv${app}${environmentShort}${uniqueString(resourceGroup().id)}', 24)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'

  }
}

output storageAccountName string = storageAccount.name
output storageAccountFqdn string = storageAccount.properties.primaryEndpoints.blob
