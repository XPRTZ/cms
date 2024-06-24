param resourceName string
param location string
param cmsUami string
param cmsUamiName string

resource postgreSql 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: resourceName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    createMode: 'Default'
    version: '16'
    storage: {
      storageSizeGB: 32
      type: 'PremiumV2_LRS'
      iops: 3000
      throughput: 125
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
    }
  }

  resource administrators 'administrators' = {
    name: cmsUami
    properties: {
      tenantId: tenant().tenantId
      principalType: 'ServicePrincipal'
      principalName: cmsUamiName
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: 'pe-xprtzbv-cms'
  location: location
  properties: {
    customNetworkInterfaceName: 'pe-xprtzbv-cms-nic'
    privateLinkServiceConnections: [
      {
        name: 'pl-xprtzbv-cms'
        properties: {
          privateLinkServiceId: postgreSql.id
          groupIds: [
            'postgresqlServer'
          ]
        }
      }
    ]
  }
}

output databaseUri string = '${postgreSql.name}.postgres.database.azure.com'
