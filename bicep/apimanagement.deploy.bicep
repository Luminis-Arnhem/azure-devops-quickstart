var apiManagementName = 'thijdemoapis'
var appInsightsName = 'thijdemoai'

resource apiManagementInstance 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apiManagementName
  location: resourceGroup().location
  sku: {
    capacity: 0
    name: 'Consumption'
  }
  properties: {
    virtualNetworkType: 'None'
    publisherEmail: 'hilmar.jansen@luminis.eu'
    publisherName: 'Hilmar Jansen'
  }
}

// application insights
resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'other'
  properties: {
    Application_Type: 'other'
  }
}

// logging and monitoring
resource apiManagement_logger_appInsights 'Microsoft.ApiManagement/service/loggers@2019-01-01' = {
  parent: apiManagementInstance
  name: 'applicationInsights'
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: reference(appInsightsComponents.id, '2015-05-01').InstrumentationKey
    }
  }
}

resource apiManagement_diagnostics_appInsights 'Microsoft.ApiManagement/service/diagnostics@2019-01-01' = {
  parent: apiManagementInstance
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apiManagement_logger_appInsights.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
  }
}

resource apiManagement_logger_azuremonitor 'Microsoft.ApiManagement/service/loggers@2020-12-01' = {
  parent: apiManagementInstance
  name: 'azuremonitor'
  properties: {
    loggerType: 'azureMonitor'
    isBuffered: true
  }
}

resource apiManagement_diagnostics_azuremonitor 'Microsoft.ApiManagement/service/diagnostics@2019-01-01' = {
  parent: apiManagementInstance
  name: 'azuremonitor'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apiManagement_logger_azuremonitor.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
  }
}

// Petshop api
resource petshopApi 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  name: 'petshop'
  parent: apiManagementInstance
  properties: {
    path: 'petshop'
    apiRevision: '1'
    displayName: 'Petshop Api'
    description: 'Petshop Api'
    subscriptionRequired: true
    serviceUrl: 'https://thijdemopetshop.azurewebsites.net/api'
    subscriptionKeyParameterNames: {
      header: 'api-key'
      query: 'api-key'
    }
    protocols: [
      'https'
    ]
  }
}

resource petshopApiPolicies 'Microsoft.ApiManagement/service/apis/policies@2020-12-01' = {
  name: 'policy'
  parent: petshopApi
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

// Basic product
resource basicProduct 'Microsoft.ApiManagement/service/products@2020-12-01' = {
  name: 'petshopbasic'
  parent: apiManagementInstance
  properties: {
    displayName: 'petshop-basic'
    description: 'Basic petshop product'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    subscriptionsLimit: 1
    terms: 'These are the terms of use ...'
  }
}

resource basicProductPolicies 'Microsoft.ApiManagement/service/products/policies@2020-12-01' = {
  name: 'policy'
  parent: basicProduct
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource linkPetshopApiToBasicProduct 'Microsoft.ApiManagement/service/products/apis@2020-12-01' = {
  name: 'petshop'
  parent: basicProduct
}

// Advanced product
resource advancedProduct 'Microsoft.ApiManagement/service/products@2020-12-01' = {
  name: 'petshopadvanced'
  parent: apiManagementInstance
  properties: {
    displayName: 'petshop-advanced'
    description: 'Advanced petshop product'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    subscriptionsLimit: 1
    terms: 'These are the terms of use ...'
  }
}

resource advancedProductPolicies 'Microsoft.ApiManagement/service/products/policies@2020-12-01' = {
  name: 'policy'
  parent: advancedProduct
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource linkPetshopApiToAdvancedProduct 'Microsoft.ApiManagement/service/products/apis@2020-12-01' = {
  name: 'petshop'
  parent: advancedProduct
}
