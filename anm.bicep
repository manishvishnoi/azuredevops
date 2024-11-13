// Parameters
param location string = resourceGroup().location
param acrName string = 'axwaymanishdevops'
param containerAppName string = 'my-anm-bicep'
param imageName string = 'anm'
param cpu int = 2
param memory string = '4Gi'
param targetPort int = 8090

// Container Registry Reference (existing)
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// Managed Environment: Create if not exists
resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' = if (!exists('Microsoft.App/managedEnvironments', managedEnvironmentName)) {
  name: managedEnvironmentName
  location: location
  properties: {
    // Define the environment properties
  }
}

// Reference the Managed Environment (either existing or newly created)
resource containerAppEnvReference 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: managedEnvironmentName
  scope: resourceGroup()
}

// Azure Container App Definition
resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvReference.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'tcp'
      }
      registries: [
        {
          server: acr.properties.loginServer
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${acr.properties.loginServer}/${imageName}:latest'
          name: containerAppName
          resources: {
            cpu: cpu
            memory: memory
          }
          env: [
            {
              name: 'ACCEPT_GENERAL_CONDITIONS'
              value: 'yes'
            }
          ]
        }
      ]
    }
  }
}
