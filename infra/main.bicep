// Entry point for declaring required Azure resources

// Parameters -----------------------------------------------------------------
@description('The deployment environment')
@allowed([
  'dev'
  'test'
  'prd'
])
param envKey string

@description('The project acronym to use for Azure resource names')
@maxLength(18) // storage accounts have a max length of 24 characters eg. sta<envKey><projectKey>
param projectKey string

@description('The azure region into which the resources should be deployed')
param location string

// Variables ------------------------------------------------------------------
@description('Tags to apply to each resource')
var resourceTags = {
  env: envKey
  location: location
  project: projectKey
}

// Resources ------------------------------------------------------------------
module functionAppResources 'modules/function-app-resources.bicep' = {
  name: 'function-app-resources-${envKey}'
  scope: resourceGroup('rg-${envKey}-${projectKey}')
  params: {
    envKey: envKey
    location: location
    projectKey: projectKey
    resourceTags: resourceTags
  }
}
