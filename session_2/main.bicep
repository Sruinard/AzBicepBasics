param storageAccountName string
param storageContainerNames array = [
  'container1'
  'container2'
]
param isAdvancedThreatProtectionEnabled bool

module storageAndContainers './modules/storage_accound_advanced_threat_protection.bicep' = {
  name: 'deployStorageAndContainers'
  params: {
    storageAccountName: storageAccountName
    storageContainerNames: storageContainerNames
    isAdvancedThreatProtectionEnabled: isAdvancedThreatProtectionEnabled
  }
}
