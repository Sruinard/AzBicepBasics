param vNetArray array
param subnetArray array

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
