// Parameters
param location string = resourceGroup().location
param acrName string = 'axwaymanishdevops'
param containerAppName string = 'my-anm-bicep'
param imageName string = 'anm'
param cpu int = 2
param memory string = '4Gi'
param targetPort int = 8090
param managedEnvironmentName string = 'managedEnvironment-RGmavishnoi-91ac-21march'

// Container Registry Reference (existing)
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// Check if the managed environment exists by attempting to reference it as an existing resource
resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: managedEnvironmentName
}

// Nested deployment to create the managed environment if it doesn’t exist
module createManagedEnv 'createManagedEnvironment.bicep' = if (empty(containerAppEnv)) {
  name: 'createManagedEnvironmentDeployment'
  params: {
    location: location
    managedEnvironmentName: managedEnvironmentName
  }
}

// Reference the Managed Environment (either existing or newly created)
resource containerAppEnvReference 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: managedEnvironmentName
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
