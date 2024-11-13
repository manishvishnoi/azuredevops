// Parameters
param location string = resourceGroup().location
param acrName string = 'axwaymanishdevops'
param containerAppName string = 'my-anm-bicep'
param imageName string = 'anm'
param cpu int = 2
param memory string = '4Gi'
param targetPort int = 8090

// Reference Existing Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// Reference Existing Azure Container App Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: 'axwaymanishdevops'
}

// Azure Container App
resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
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
