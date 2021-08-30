param vNetArray array
param subnetArray array
param tenantId string
param location string = resourceGroup().location
param keyVaultName string = 'rabokeyvaultsrrabo'
param keyVaultSKU string = 'standard'
param keyVaultRole string = '4633458b-17de-408a-b874-0445c86b69e6'
param keyVaultSecretName string = 'TestSecret'
param keyVaultSecretValue string = 'This message is from keyvault'

//Vnet build out
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = [for (vnet, i) in vNetArray: {
  name: '${vnet.vnetName}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet.vNetAddressSpace
      ]
    }
    enableDdosProtection: false
    // recommended to NOT create subnets as separate resources. Might result in vnet[0].properties.subnets[0].id) would result error ‘array index ‘0’ is out of 
    subnets: [for (subnet, i) in subnetArray: {
      name: 'subnets-${subnet.vNetName}-${subnet.subnetName}-${i}'
      properties: {
        addressPrefix: subnet.SubnetAddressSpace
        serviceEndpoints: subnet.serviceEndPoints
      }
    }]
  }
}]


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appconfigmi'
  tags: {}
  location: location
  dependsOn: [
    vnet
  ]
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: false
    tenantId: tenantId
    sku: {
      name: keyVaultSKU
      family: 'A'
    }
    networkAcls:{
      defaultAction: 'Deny'
      virtualNetworkRules:[
        {
          ignoreMissingVnetServiceEndpoint: false
          id: vnet[0].properties.subnets[0].id
        }
      ]
    }
  }
}

// Module 6: Deploy KeyVault secret
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/${keyVaultSecretName}'
  properties: {
    value: keyVaultSecretValue
  }
  dependsOn: [
     keyVault
  ]
}

// Assign Scope 
resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('AppConfigUser', keyVaultName , subscription().subscriptionId)
  scope: keyVault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultRole)
    principalId: managedIdentity.properties.principalId
    // specify principal type to overcome issues with propagation issues: https://docs.microsoft.com/bs-latn-ba/azure/role-based-access-control/role-assignments-template#new-service-principal
    principalType: 'ServicePrincipal'
  }
  dependsOn:[
    keyVault
    managedIdentity
  ]
}
