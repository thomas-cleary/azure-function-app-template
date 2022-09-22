// Parameters ----------------------------------------------------------------- 
@description('The name of the environment to deploy to')
@allowed([
  'dev'
  'test'
  'prd'
])
param envKey string

@description('The azure region to deploy the resources to')
@allowed([
  'australiaeast'
])
param location string = 'australiaeast'

@description('The name of the project these resources are being provisioned for.')
param projectName string

@description('The acronym of the project these resources are being provisioned for.')
@minLength(1)
@maxLength(18) // need 3 chars for 'sta' at end + 3 for env name (max length is 24 for storage account)
param projectAcronym string

@description('Tags for the resources')
param resourceTags object

// Variables -----------------------------------------------------------------
@description('Full resource name suffix')
var fullNameSuffix = '${envKey}-${projectName}'

@description('Name for storage account resource')
var storageAccountName = toLower('sta${envKey}${replace(projectAcronym, '-', '')}') // Name cannot contain '-' chars

@description('Name for application insights resource')
var appInsightsName = toLower('ains-${fullNameSuffix}')

@description('Name for app service plan resource')
var appServicePlanName = toLower('asp-${fullNameSuffix}')

@description('Name for function app resource')
var functionAppName = toLower('fa-${fullNameSuffix}')

@description('The function app runtime to use')
var functionRuntime = 'dotnet'

@description('The function app extension version to use')
var functionAppExtensionVersion = '~4'

@description('Config for function app')
var functionAppConfig = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  }
  {
    name: 'APPINSIGHTS_CONNECTIONSTRING'
    value: 'Instrumentationkey=${appInsights.properties.InstrumentationKey}'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: functionAppExtensionVersion
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: functionRuntime
  }
  {
    name: 'ENVIRONMENT_NAME'
    value: envKey
  }
]

@description('URIs allowed to make requests to the functionapp in NPE')
var functionAppAllowedOriginsNPE = [
  '*'
]

@description('URIs allowed to make requests to the functionapp in PRD.')
var functionAppAllowedOriginsPRD = [
  '*'
]

// Resources -----------------------------------------------------------------
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags: resourceTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: resourceTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  tags: resourceTags
  kind: 'linux'
  sku: {
    name: 'Y1' // Consumption plan SKU = 'Y1'
  }
  properties: {
    reserved: true // required for operating system to be set to 'Linux'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  tags: resourceTags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: functionAppConfig
      cors: {
        allowedOrigins: envKey == 'prd' ? functionAppAllowedOriginsPRD : functionAppAllowedOriginsNPE
      }
    }
  }
}

// Outputs -------------------------------------------------------------------
