param resourceGroupName string
param dnsZoneName string
param appVnetName string
param privateEndpointName string
param dnsZoneLinkName string
param dnsZoneGroupName string

// Reference existing VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: appVnetName
  scope: resourceGroup(resourceGroupName)
}

// Reference existing Private Endpoint (no explicit scope to avoid scope mismatch)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' existing = {
  name: privateEndpointName
}

// Create the Private DNS Zone
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  dependsOn: [
    privateEndpoint
  ]
  location: 'global'
  
}

// Link the DNS zone to the VNet
resource dnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: dnsZoneLinkName
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

// Attach the DNS zone to the Private Endpoint via DNS Zone Group
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: dnsZoneGroupName
  parent: privateEndpoint
  dependsOn: [
    privateEndpoint
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'sqlDnsZone'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

