// Parameters
param location string
param managedEnvironmentName string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: managedEnvironmentName
  location: location
  properties: {
    // Define the environment properties as needed
  }
}
