// To deploy a Resource Group the scope needs to be the subscription it is deployed into
targetScope = 'subscription'

// Parameters ----------------------------------------------------------------
@description('The name of the environment resources should be deployed to should represent.')
@allowed([
  'dev'
  'test'
  'prd'
])
param envKey string

@description('The name of the project these resources are being provisioned for.')
param projectName string

@description('The azure region into which the resources should be deployed')
@allowed([
  'australiaeast'
])
param location string

// Variables ------------------------------------------------------------------
@description('Name for the resource group')
var resourceGroupName = toLower('rg-${envKey}-${projectName}')

@description('Tags to apply to each resource')
var resourceTags = {
  env: envKey
  location: location
  project: projectName
}

// Resources -----------------------------------------------------------------
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: resourceTags
}
