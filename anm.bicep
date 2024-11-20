param acrName string = 'axwaymanishdevops'
param imageName string = 'anm'
param containerAppName string = 'my-anm-bicep'
param managedEnvironmentName string = 'managedEnvironment-RGmavishnoi-91ac-21march'
param targetPort int = 8090
param acrPassword string

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: 'northeurope' // Replace with your desired location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', managedEnvironmentName)
    configuration: {
      registries: [
        {
          server: '${acrName}.azurecr.io'
          username: acrName
          passwordSecretRef: 'acr-password' // Updated to valid secret name
        }
      ]
      ingress: {
        external: true
        targetPort: targetPort
      }
      secrets: [
        {
          name: 'acr-password' // Updated to valid secret name
          value: acrPassword
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: '${acrName}.azurecr.io/${imageName}:latest'
          resources: {
            cpu: 2
            memory: '4Gi'
          }
          env: [ // Added environment variables
            {
              name: 'ACCEPT_GENERAL_CONDITIONS'
              value: 'yes'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}
