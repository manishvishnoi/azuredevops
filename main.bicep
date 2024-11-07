param acrName string = 'axwaytest221' // Must be globally unique
param resourceGroupName string = 'RG-mavishnoi'
param location string = 'westus' // Specify the region, e.g., eastus, westus

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
