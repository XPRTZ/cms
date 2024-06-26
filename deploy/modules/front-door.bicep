@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string

@description('The hostname of the origin to use for the Front Door endpoint.')
param originHostname string

var sharedValues = json(loadTextContent('../shared-values.json'))
var subscriptionId = sharedValues.subscriptionIds.common
var frontDoorProfileName = 'afd-xprtzbv-website'
var frontDoorOriginGroupName = 'xprtzbv-cms'
var frontDoorOriginName = 'xprtzv-cms'
var frontDoorRouteName = 'xpzrtbv-cms-route'
var customDomainWwwName = 'cms-xprtz-dev'
var cnameRecordName = 'cms'

resource customDomainWww 'Microsoft.Cdn/profiles/customDomains@2023-07-01-preview' = {
  name: customDomainWwwName
  parent: frontDoorProfile
  properties: {
    hostName: 'cms.xprtz.dev'
    azureDnsZone: {
      id: resourceId(subscriptionId, 'xprtz-mgmt', 'Microsoft.Network/dnszones', 'xprtz.dev')
    }
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

module dns 'dns.bicep' = {
  name: 'Deploy-DNS-Records'
  scope: resourceGroup(subscriptionId, 'xprtz-mgmt')
  params: {
    frontDoorEndpointHostName: frontDoorEndpoint.properties.hostName
    cnameRecordName: cnameRecordName
    cnameValidation: customDomainWww.properties.validationProperties.validationToken
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-07-01-preview' existing = {
  name: frontDoorProfileName
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-07-01-preview' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2023-07-01-preview' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 120
    }

  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-07-01-preview' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: originHostname
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostname
    priority: 1
    weight: 1000

  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-07-01-preview' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    customDomains: [
      {
        id: customDomainWww.id
      }
    ]
  }
}
