@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@description('The number of App Service plan instances.')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('The object id that will be granted key vault access.')
param objectId string



@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var keyVaultName = '${environmentName}-${solutionName}-kv'

resource appServiceKeyVault 'Microsoft.KeyVault/vaults@2020-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
     sku: {
      family: 'A'
      name: 'standard'
     }
     tenantId: subscription().tenantId
     enabledForDeployment: true
     accessPolicies: [
       {
          objectId: objectId
          tenantId: subscription().tenantId
          permissions: {
            secrets: [
              'get'
              'list'
              'set'
              'delete'
            ]
          }
       }
     ]
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource appServiceSecrets 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  dependsOn: [
    appServiceApp
  ]
  parent: appServiceKeyVault
  name: 'endpoint'
  properties: {
    value: 'https://${appServiceApp.properties.defaultHostName}/'
  }
}

output endpoint string = 'https://${appServiceApp.properties.defaultHostName}/'
