param resourceName string
param location string
param administratorLogin string
@secure()
param administratorLoginPassword string

resource postgreSql 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: resourceName
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

  resource allowEntraAdministrator 'administrators' = {
    name: '4add9805-c69a-45c5-bbfd-fdcdb4a945e7'
    properties: {
      principalName: 'maarten@xprtz.net'
      principalType: 'User'
      tenantId: '2a600bfa-5bb2-40e6-b33b-12bf8b7fa696'
    }
  }

  resource allowAllWindowsAzureIps 'firewallRules' = {
    name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

output databaseUri string = '${postgreSql.name}.postgres.database.azure.com'
