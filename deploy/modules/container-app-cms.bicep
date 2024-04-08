param location string
param keyVaultName string
param containerAppUserAssignedIdentityResourceId string
param containerAppUserAssignedIdentityClientId string
param logAnalyticsWorkspaceName string
param imageTag string = 'latest'

var name = take('ctap-xprtzbv-cms-${imageTag}', 32)

var acrServer = 'xprtzbv.azurecr.io'
var imageName = '${acrServer}/cms:${imageTag}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

module containerAppEnvironment 'container-app-environment.bicep' = {
  name: 'Deploy-Container-App-Environment'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-08-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerAppUserAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvironment.outputs.containerAppEnvironmentId
    configuration: {
      registries: [
        {
          server: acrServer
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
      ingress: {
        external: true
        targetPort: 1337
      }
      secrets: [
        {
          name: toLower('REF-APP-KEYS')
          keyVaultUrl: toLower('https://kv-xprtzbv-cms.vault.azure.net/secrets/APP-KEYS')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-API-TOKEN-SALT')
          keyVaultUrl: toLower('https://kv-xprtzbv-cms.vault.azure.net/secrets/API-TOKEN-SALT')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-ADMIN-JWT-SECRET')
          keyVaultUrl: toLower('https://kv-xprtzbv-cms.vault.azure.net/secrets/ADMIN-JWT-SECRET')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-TRANSFER-TOKEN-SALT')
          keyVaultUrl: toLower('https://kv-xprtzbv-cms.vault.azure.net/secrets/TRANSFER-TOKEN-SALT')
          identity: containerAppUserAssignedIdentityResourceId
        }
        {
          name: toLower('REF-JWT-SECRET')
          keyVaultUrl: toLower('https://kv-xprtzbv-cms.vault.azure.net/secrets/JWT-SECRET')
          identity: containerAppUserAssignedIdentityResourceId
        }
      ]
    }
    template: {
      serviceBinds: [
        {
          serviceId: containerAppEnvironment.outputs.postgresId
        }
      ]
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
              name: 'NODE_ENV'
              value: 'production'
            }
            {
              name: 'PORT'
              value: '1337'
            }
            {
              name: 'APP_KEYS'
              secretRef: toLower('REF-APP-KEYS')
            }
            {
              name: 'API_TOKEN_SALT'
              secretRef: toLower('REF-API-TOKEN-SALT')
            }
            {
              name: 'ADMIN_JWT_SECRET'
              secretRef: toLower('REF-ADMIN-JWT-SECRET')
            }
            {
              name: 'TRANSFER_TOKEN_SALT'
              secretRef: toLower('REF-TRANSFER-TOKEN-SALT')
            }
            {
              name: 'JWT_SECRET'
              secretRef: toLower('REF-JWT-SECRET')
            }
          ]
        }
      ]
      scale: {
       minReplicas: 1
       maxReplicas: 1
      }
    }
  }
}

resource pgsqlCli 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: 'pgsql-cli'
  location: location
  properties: {
    environmentId: containerAppEnvironment.outputs.containerAppEnvironmentId
    template: {
      serviceBinds: [
        {
          serviceId: containerAppEnvironment.outputs.postgresId
        }
      ]
      containers: [
        {
          name: 'psql'
          image: 'mcr.microsoft.com/k8se/services/postgres:14'
          command: [ '/bin/sleep', 'infinity' ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

resource pgweb 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: 'pgweb'
  location: location
  properties: {
    environmentId: containerAppEnvironment.outputs.containerAppEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 8081
      }
    }
    template: {
      serviceBinds: [
        {
          serviceId: containerAppEnvironment.outputs.postgresId
        }
      ]
      containers: [
        {
          name: 'pgweb'
          image: 'docker.io/sosedoff/pgweb:latest'
          command: [
            '/bin/sh'
          ]
          args: [
            '-c'
            'PGWEB_DATABASE_URL=$POSTGRES_URL /usr/bin/pgweb --bind=0.0.0.0 --listen=8081'
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output containerAppUrl string = containerApp.properties.latestRevisionFqdn
