param storageAccount object
param storageContainerNames array

resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2020-08-01-preview' = [for containerName in storageContainerNames: {
  name: '${storageAccount.name}/default/${containerName}'
}]

output containers array = [for i in range(0, length(storageContainerNames)): {
      resource_id: storageAccountContainer[i].id
      name: storageAccountContainer[i].name
  }]

