

@description('The location of the resources')
param location string = resourceGroup().location

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the App Service')
param appServiceName string

// @description('Key Vault URI to retrieve connection string')
// param keyVaultUri string
@secure()
param sqlAdminPasswordSecret string
param sqlServerName string
param sqlAdminUsername string
param databaseName string
param subnetId string
// param keyVaultResourceId string





resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
  }
  kind: 'linux'
}

// Construct the SQL connection string with username and password
var connectionString = 'Server=tcp://${sqlServerName}.database.windows.net,1433;Initial Catalog=${databaseName};User ID=${sqlAdminUsername};Password=${sqlAdminPasswordSecret};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;'


resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: appServiceName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    virtualNetworkSubnetId: subnetId
    siteConfig: {
      appSettings: [
        {
          name: 'ConnectionStrings__SQLDatabase'
          value: connectionString
        }
      ]
      alwaysOn: true
      vnetRouteAllEnabled: true // Moved inside siteConfig to enable VNet routing
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Auto-scaling configuration for CPU usage
resource autoScale 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${appServicePlanName}-autoscale'
  location: location
  properties: {
    enabled: true
    targetResourceUri: appServicePlan.id
    profiles: [
      {
        name: 'CPU-based autoscale'
        capacity: {
          minimum: '1'
          maximum: '10'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 75
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 25
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}


resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2021-02-01' = {
  parent: appService
  name: 'vnet'
  properties: {
    vnetResourceId: subnetId // Ensure this is the full resource ID of the AppServiceSubnet
    isSwift: true // Enable streamlined (swift) VNet integration
  }
}


resource vnetConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = {
  parent: appService
  name: 'AppServiceSubnet'
  properties: {
    vnetResourceId: subnetId // Use the VNet subnet ID for integration
    isSwift: true  // Enables fast VNet integration (if desired)
  }
}


output principalId string = appService.identity.principalId
