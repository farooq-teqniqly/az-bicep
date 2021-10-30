targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: 'fm-d-euw-bicep-mslearn-rg'
  location: deployment().location
}

param environmentName string
param appServicePlanInstanceCount int
param appServicePlanSku object

module appServiceDeploy 'appService.bicep' = {
  name: 'appServiceDeploy'
  scope: rg
  params: {
     environmentName: environmentName
     solutionName: 'fm-solution-01'
     appServicePlanInstanceCount: appServicePlanInstanceCount
     appServicePlanSku: appServicePlanSku
  }
}
