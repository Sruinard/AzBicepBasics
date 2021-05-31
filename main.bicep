param storageAccountName string
param storageContainerNames array = [
  'container1'
  'container2'
]
param location string = resourceGroup().location

module storageModule './modules/sa.bicep' = {
  name: 'storageDeploy'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module blobModule './modules/sa_containers.bicep' = {
  name: 'containerDeploy'
  params: {
    storageAccount: storageModule
    storageContainerNames: storageContainerNames
  }
}

output containers array = blobModule.outputs.containers
output resources object = resourceGroup()
