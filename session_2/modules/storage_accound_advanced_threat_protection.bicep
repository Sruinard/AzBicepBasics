@minLength(3)
@maxLength(10)
param storageAccountName string
param storageContainerNames array
param location string = resourceGroup().location

param isAdvancedThreatProtectionEnabled bool

var uniqueStorageAccountName = '${storageAccountName}${uniqueString(resourceGroup().id)}'

// create storage account
resource stg 'microsoft.storage/storageAccounts@2021-01-01' = {
  name: uniqueStorageAccountName
  location: location
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource storageAccountContainers 'Microsoft.Storage/StorageAccounts/BlobServices/containers@2021-04-01' = [for containerName in storageContainerNames: {
  name: '${stg.name}/default/${containerName}'
}]
// Specifing the scope is important. See linking in visualizer.
resource atps 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = if (isAdvancedThreatProtectionEnabled) {
  name: 'current'
  scope: stg
  properties: {
    isEnabled: true
  }
}
