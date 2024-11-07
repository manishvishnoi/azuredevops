param acrName string = 'axwaytest2210' // Must be globally unique
param resourceGroupName string = 'RG-mavishnoi'
param location string = 'westeurope' // Specify the region, e.g., eastus, westus

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output registryName string = containerRegistry.name
