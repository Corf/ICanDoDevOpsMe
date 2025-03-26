@minLength(3)
param location string = resourceGroup().location
@secure()
param sqlAdminPassword string
param sqlAdminUsername string
param appServiceName string
param sqlServerName string 
param appVnetName string
param myAppServicePlan string
param databaseName string

param resourceGroupName string
param dnsZoneName string
param privateEndpointName string
param dnsZoneLinkName string
param dnsZoneGroupName string

/// create Vnet/subnets and apply delegation for the serverFarms
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: appVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AppServiceSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'SQLDatabaseSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

// Module to deploy the SQL Server, passing in the secret as a parameter
module sql './sql.bicep' = {
  name: 'deploySQL-${uniqueString(resourceGroup().id)}'
  params: {
    vnetName: appVnetName
    subnetName: 'SQLDatabaseSubnet'
    databaseName: databaseName
    sqlServerName: sqlServerName
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    location: location
  }
}

// Module to create the app Service
module appServiceModule 'appService.bicep' = {
  name: 'AppServiceDeployment'
  params: {
    sqlServerName: sqlServerName
    sqlAdminUsername: sqlAdminUsername
    databaseName: databaseName
    sqlAdminPasswordSecret: sqlAdminPassword //keyVault.getSecret(sqlAdminPasswordSecretName) // Retrieves the secret
    location: location
    appServicePlanName: myAppServicePlan
    appServiceName: appServiceName
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', appVnetName, 'AppServiceSubnet')
  }
}

// Module to create a private DNS so you can loginto the SQL server via Private connection
module privateDNS 'privateDNS.bicep' = {
  name: 'privateDNSModule'
  dependsOn: [sql]
  params: {
    resourceGroupName: resourceGroupName
    dnsZoneName: dnsZoneName
    appVnetName: appVnetName
    privateEndpointName: privateEndpointName
    dnsZoneLinkName: dnsZoneLinkName
    dnsZoneGroupName: dnsZoneGroupName
  }
}
