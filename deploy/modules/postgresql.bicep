param databaseServerName string
param location string
param administratorLogin string
@secure()
param administratorLoginPassword string

resource postgreSql 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: databaseServerName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    createMode: 'Default'
    replicationRole: 'Primary'
    version: '14'
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
    backup: {
      backupRetentionDays: 31
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }

  resource databases 'databases' = {
    name: 'strapi'
  }

  resource allowAllWindowsAzureIps 'firewallRules' = {
    name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

output databaseName string = postgreSql.name
output databaseUri string = '${postgreSql.name}.postgres.database.azure.com'
