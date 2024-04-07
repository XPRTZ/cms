param location string
param containerAppUserAssignedIdentityResourceId string
param containerAppUserAssignedIdentityClientId string
param logAnalyticsWorkspaceName string
param imageTag string = 'latest'

var name = take('ctap-xprtzbv-cms-${imageTag}', 32)

var acrServer = 'xprtzbv.azurecr.io'
var imageName = '${acrServer}/cms:${imageTag}'

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
    }
    template: {
      serviceBinds: [
        {
          serviceId: containerAppEnvironment.outputs.postgresId
          name: 'pgsql-xprtzbv-cms'
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
          ]
        }
      ]
      scale: {
       minReplicas: 1
       maxReplicas: 10
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

output containerAppUrl string = containerApp.properties.latestRevisionFqdn
