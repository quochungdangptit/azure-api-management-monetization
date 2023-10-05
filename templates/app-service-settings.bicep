param webSiteName string

param apimServiceName string

param paymentProvider string

// Required for Stripe
param stripePublicKey string = ''
param stripeApiKey string = ''

// Required for Adyen
param adyenApiKey string = ''
param adyenClientKey string = ''
param adyenMerchantAccount string = ''

param containerPort int

param servicePrincipalAppId string

@secure()
param servicePrincipalPassword string
param servicePrincipalTenantId string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName

  resource masterSubscription 'subscriptions@2019-01-01' existing = {
    name: 'master'
  }

  resource serviceDelegation 'portalsettings@2018-01-01' existing = {
    name: 'delegation'
  }
}

resource webSite 'Microsoft.Web/sites@2018-11-01' existing = {
  name: webSiteName
}

resource webSiteAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webSite
  name: 'appsettings'
  properties: {
    NODE_ENV: 'production'
    SERVER_PORT: '8000'
    APIM_MANAGEMENT_URL: apiManagementService.properties.managementApiUrl
    APIM_GATEWAY_URL: apiManagementService.properties.gatewayUrl
    APIM_DEVELOPER_PORTAL_URL: apiManagementService.properties.developerPortalUrl
    APIM_ADMIN_SUBSCRIPTION_KEY: apiManagementService::masterSubscription.properties.primaryKey
    STRIPE_PUBLIC_KEY: stripePublicKey
    STRIPE_API_KEY: stripeApiKey
    WEBSITES_PORT: string(containerPort)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    APIM_SERVICE_NAME: apimServiceName
    APIM_SERVICE_AZURE_SUBSCRIPTION_ID: subscription().subscriptionId
    APIM_SERVICE_AZURE_RESOURCE_GROUP_NAME: resourceGroup().name
    APIM_DELEGATION_VALIDATION_KEY: apiManagementService::serviceDelegation.properties.validationKey
    AZURE_AD_SERVICE_PRINCIPAL_APP_ID: servicePrincipalAppId
    AZURE_AD_SERVICE_PRINCIPAL_PASSWORD: servicePrincipalPassword
    AZURE_AD_SERVICE_PRINCIPAL_TENANT_ID: servicePrincipalTenantId
    PAYMENT_PROVIDER: paymentProvider
    ADYEN_MERCHANT_ACCOUNT: adyenMerchantAccount
    ADYEN_CLIENT_KEY: adyenClientKey
    ADYEN_API_KEY: adyenApiKey
  }
}

output webSiteUrl string = webSite.properties.defaultHostName
