param storageAccountName string
param storageContainerNames array = [
  'container1'
  'container2'
]

module storageAndContainers './modules/sa_and_containers.bicep' = {
  name: 'deployStorageAndContainers'
  params: {
    storageAccountName: storageAccountName
    storageContainerNames: storageContainerNames
  }
}
