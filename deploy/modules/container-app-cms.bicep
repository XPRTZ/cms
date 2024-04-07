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
          name: 'postgres'
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

output containerAppUrl string = containerApp.properties.latestRevisionFqdn
