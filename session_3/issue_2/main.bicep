
@description('The principal to assign the role to')
param principalId string

@allowed([
  'Owner'
  'Contributor'
  'Reader'
])
@description('Built-in role to assign')
param builtInRoleType string

@description('A new GUID used to identify the role assignment')
param location string = resourceGroup().location

var uniqueStorageName = 'storage${uniqueString(resourceGroup().id)}'

resource demoStorageAcct 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {}
}

module saAssign './modules/role_assignment.bicep' = {
  name: 'roleNameRabo'
  params: {
    builtInRoleType: builtInRoleType
    principalId: principalId
    storageName: demoStorageAcct.name
  }
}
