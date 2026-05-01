// Main Bicep template for Azure Deployment Stacks
// Deploys infrastructure resources using modular components

// Parameters
@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Environment name (e.g., dev, staging, prod)')
param environment string

@description('Project name for resource naming')
param projectName string = 'stack'

@description('Organization prefix for resource naming')
param orgPrefix string = ''

@description('Storage account SKU')
param storageSkuName string = 'Standard_LRS'

@description('Storage account access tier')
param storageAccessTier string = 'Hot'

// Load variables module
module variables 'variables.bicep' = {
  name: 'variablesModule'
  params: {
    location: location
    environment: environment
    projectName: projectName
    orgPrefix: orgPrefix
  }
}

// Deploy storage account
module storageModule 'modules/storage.bicep' = {
  name: 'storageModule'
  params: {
    storageAccountName: variables.outputs.storageAccountName
    location: location
    skuName: storageSkuName
    accessTier: storageAccessTier
    tags: variables.outputs.commonTags
  }
}

module hostingPlanModule 'modules/plan.bicep' = {
  name: 'hostingPlanModule'
  params: {
    hostingPlanName: 'plan-${variables.outputs.resourcePrefix}'
    location: location
  }
}

var userAssignedIdentityName = 'uai-${variables.outputs.resourcePrefix}'

module identityModule 'modules/identity.bicep' = {
  name: 'identityModule'
  params: {
    userAssignedIdentityName: userAssignedIdentityName
    location: location
  }
}

module storagePermissionsModule 'modules/storage-function-permissions.bicep' = {
  name: 'storagePermissionsModule'
  params: {
    storageAccountName: storageModule.outputs.storageAccountName
    userAssignedIdentityName: userAssignedIdentityName
  }
}

module functionAppModule 'modules/function.bicep' = {
  name: 'functionAppModule'
  params: {
    functionAppName: 'func-${variables.outputs.resourcePrefix}'
    location: location
    hostingPlanId: hostingPlanModule.outputs.hostingPlanId
    storageAccountName: storageModule.outputs.storageAccountName
    userAssignedIdentityName: userAssignedIdentityName
    // applicationInsightsName: 'appinsights-${variables.outputs.resourcePrefix}'
  }
}

// Load outputs module
module outputsModule 'outputs.bicep' = {
  name: 'outputsModule'
  params: {
    storageAccountId: storageModule.outputs.storageAccountId
    storageAccountName: storageModule.outputs.storageAccountName
    primaryBlobEndpoint: storageModule.outputs.primaryBlobEndpoint
    resourceGroupName: resourceGroup().name
    environment: environment
  }
}

// Root outputs
output deploymentInfo object = outputsModule.outputs.deploymentInfo
output storageAccountName string = outputsModule.outputs.storageAccountName
output storageAccountId string = outputsModule.outputs.storageAccountId
output primaryBlobEndpoint string = outputsModule.outputs.primaryBlobEndpoint
output environment string = outputsModule.outputs.environment
