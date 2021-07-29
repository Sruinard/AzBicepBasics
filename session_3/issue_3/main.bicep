param vNetArray array
param subnetArray array
param tenantId string
param location string = resourceGroup().location
param keyVaultName string = 'rabokeyvaultsr'
param keyVaultSKU string = 'standard'

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
  }
}]

module subnets 'modules/basic_subnet.bicep' = [for (subnet, i) in subnetArray: {
  name: 'subnets-${subnet.vNetName}-${subnet.subnetName}-${i}'
  params: {
    vNetName: subnet.vNetName
    subnetName: subnet.subnetName
    subnetAddressPrefix: subnet.SubnetAddressSpace
    serviceEndPoints: subnet.serviceEndPoints
  }
}]


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'appconfigmi'
  tags: {}
  location: location
  dependsOn: [
    subnets
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
module keyvaultSecretModule '../Rabo/Templates/KeyVault/keyvault_secret_module.bicep' = {
  name: 'keyVaultSecretDeploy'
  params: {
    keyVaultName: keyVault.name
    keyVaultSecretName: 'TestSecret'
    keyVaultSecretValue: 'This message is from keyvault'
  }
}
