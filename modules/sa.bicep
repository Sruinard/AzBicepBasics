@minLength(3)
@maxLength(10)
param storageAccountName string
param location string = resourceGroup().location

var uniqueStorageAccountName = '${storageAccountName}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: uniqueStorageAccountName
  location: location
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

// Not sure why this is assigned to 
// a variable instead of 'importing' the module
output storageAccountCreated object = storageAccount
