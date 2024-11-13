// Parameters
param location string = resourceGroup().location
param acrName string = 'axwaymanishdevops'
param containerAppName string = 'my-anm-app'
param imageName string = 'myapp'
param acrSku string = 'Basic'  // ACR SKU type (Basic, Standard, Premium)
param cpu int = 2
param memory string = '4Gi'
param targetPort int = 8090

// Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  adminUserEnabled: true  // Enable admin access for Docker login
}

// Output ACR Login Server
output acrLoginServer string = acr.properties.loginServer

// Azure Container App Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: 'managedEnvironment-RGmavishnoi-91ac-21march'
  location: location
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
          username: acr.listCredentials().username
          password: acr.listCredentials().passwords[0].value
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
