param location string
param keyVaultName string
param containerAppUserAssignedIdentityResourceId string
param containerAppUserAssignedIdentityClientId string
param deployTime int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
param app string = 'cms'
param environment string = 'preview'

var environmentShort = environment == 'preview' ? 'prv' : 'prd'
var name = take('ctap-xprtzbv-cms-database', 32)
//var namePgweb = take('ctap-xprtzbv-cms-pgweb', 32)
var acrServer = 'xprtzbv.azurecr.io'
var imageName = 'postgres:16'
var initImageName = '${acrServer}/cms/init:latest'
var administratorLogin = 'cmsadmin'
var deployTimeInSecondsSinceEpoch = string(deployTime)
var storageAccountName = take('stxprtzbv${app}${environmentShort}${uniqueString(az.resourceGroup().id)}', 24)

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' existing = {
  name: 'me-xprtzbv-cms'
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      days: 7
      enabled: true
    }
  }
}

resource databaseFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  name: 'database'
  parent: fileServices
  properties: {
    accessTier: 'Hot'
    enabledProtocols: 'SMB'
    shareQuota: 102400
  }
}

resource containerAppDatabase 'Microsoft.App/containerApps@2023-08-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerAppUserAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      registries: [
        {
          server: acrServer
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
      ingress: {
        external: false
        targetPort: 5432
        transport: 'tcp'
      }
      secrets: [
        {
          name: toLower('POSTGRES-ADMIN-PASSWORD')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/POSTGRES-ADMIN-PASSWORD')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('POSTGRES-STRAPI-PASSWORD')
          keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/POSTGRES-STRAPI-PASSWORD')
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
    }
    template: {
      containers: [
        {
          name: name
          image: imageName
          resources: {
            cpu: 1
            memory: '2Gi'
          }
          env: [
            {
              name: 'AZURE_CLIENT_ID'
              value: containerAppUserAssignedIdentityClientId
            }
            {
              name: 'DEPLOY_TIME_IN_SECONDS_SINCE_EPOCH'
              value: deployTimeInSecondsSinceEpoch
            }
            {
              name: 'POSTGRES_PASSWORD'
              secretRef: toLower('POSTGRES-ADMIN-PASSWORD')
            }
            {
              name: 'POSTGRES_USER'
              value: toLower(administratorLogin)
            }
            {
              name: 'PG_DATA'
              value: '/data'
            }
          ]
          volumeMounts: [
            {
              mountPath: '/data'
              volumeName: 'database'
            }
          ]
        }
      ]
      initContainers: [
        {
          name: 'database-init'
          image: initImageName
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'ADMINPASSWORD'
              secretRef: toLower('POSTGRES-ADMIN-PASSWORD')
            }
            {
              name: 'STRAPIPASSWORD'
              secretRef: toLower('POSTGRES-STRAPI-PASSWORD')
            }
            {
              name: 'ADMINUSER'
              value: administratorLogin
            }
            {
              name: 'SERVER'
              value: 'localhost'
            }
            {
              name: 'STRAPIUSER'
              value: 'strapi'
            }
            {
              name: 'STRAPIDATABASENAME'
              value: 'strapi'
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'database'
          storageName: 'database'
          storageType: 'AzureFile'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

// resource containerAppPgweb 'Microsoft.App/containerApps@2023-08-01-preview' = {
//   name: namePgweb
//   location: location
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${containerAppUserAssignedIdentityResourceId}': {}
//     }
//   }
//   properties: {
//     environmentId: containerAppEnvironment.id
//     configuration: {
//       ingress: {
//         external: true
//         targetPort: 8081
//       }
//       secrets: [
//         {
//           name: toLower('POSTGRES-ADMIN-PASSWORD')
//           keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/POSTGRES-ADMIN-PASSWORD')
//           identity: containerAppUserAssignedIdentityResourceId
//         }
//         {
//           name: toLower('POSTGRES-STRAPI-PASSWORD')
//           keyVaultUrl: toLower('${keyVault.properties.vaultUri}secrets/POSTGRES-STRAPI-PASSWORD')
//           identity: containerAppUserAssignedIdentityResourceId
//         }
//       ]
//     }
//     template: {
//       containers: [
//         {
//           name: namePgweb
//           image: 'docker.io/sosedoff/pgweb:latest'
//           resources: {
//             cpu: 1
//             memory: '2Gi'
//           }
//           env: [
//             {
//               name: 'POSTGRES_PASSWORD'
//               secretRef: toLower('POSTGRES-ADMIN-PASSWORD')
//             }
//             {
//               name: 'POSTGRES_USER'
//               value: toLower(administratorLogin)
//             }
//             {
//               name: 'PGWEB_DATABASE_URL'
//               //postgres://user:password@host:port/database?sslmode=[mode]
//               value: 'postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@${containerAppDatabase.properties.latestRevisionFqdn}:5432/cmsadmin?sslmode=disable'
//             }
//           ]
//         }
//       ]
//       scale: {
//         minReplicas: 0
//         maxReplicas: 1
//       }
//     }
//   }
// }

output containerAppDatabaseUrl string = containerAppDatabase.properties.latestRevisionFqdn
//output containerAppPgwebUrl string = containerAppPgweb.properties.latestRevisionFqdn
