@minLength(3)
@maxLength(10)
param storageAccountName string
param storageContainerNames array
param location string = resourceGroup().location

var uniqueStorageAccountName = '${storageAccountName}${uniqueString(resourceGroup().id)}'

// create storage account
resource stg 'microsoft.storage/storageAccounts@2019-06-01' = {
  name: uniqueStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// create storage account containers
resource storageAccountContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2020-08-01-preview' = [for containerName in storageContainerNames: {
  name: '${stg.name}/default/${containerName}'
}]

