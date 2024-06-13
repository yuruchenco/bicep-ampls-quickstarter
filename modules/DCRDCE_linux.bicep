param location string
param vmName string
param LawId string
param LawName string
// param AMPLS object

resource DCELinux 'Microsoft.Insights/dataCollectionEndpoints@2021-09-01-preview' = {
  name: 'dce-ampls'
  location: location
  kind: 'Linux'
  properties: {
    configurationAccess: {}
    // description: 'string'
    // immutableId: 'string'
    logsIngestion: {}
    networkAcls: {
      //あとでDisabledにする
      publicNetworkAccess: 'Disabled'
    }
  }
}

// DCRの作成
// resource DCRLinux 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
//   name: 'dcr-ampls-linux'
//   location: location
//   kind: 'Linux'
//   properties: {
//     dataCollectionEndpointId: DCELinux.id
//     dataFlows: [
//       {
//         streams: [
//           'Microsoft-Syslog'
//         ]
//         destinations: [
//           'azureMonitorMetrics-default'
//         ]
//       }
//     ]
//     dataSources: {
//       syslog: [
//         {
//           name: 'sysLogsDataSource'
//           streams: [
//             'Microsoft-Syslog'
//           ]
//           facilityNames: [
//             'alert'
//             'audit'
//             'auth'
//             'authpriv'
//             'clock'
//             'cron'
//             'daemon'
//             'ftp'
//             'kern'
//             'local0'
//             'local1'
//             'local2'
//             'local3'
//             'local4'
//             'local5'
//             'local6'
//             'local7'
//             'lpr'
//             'mail'
//             'news'
//             'nopri'
//             'ntp'
//             'syslog'
//             'user'
//             'uucp'
//         ]
//         logLevels: [
//             'Info'
//             'Notice'
//             'Warning'
//             'Error'
//             'Critical'
//             'Alert'
//             'Emergency'
//         ]
//         }
//       ]
//     }
//     // description: 'string'
//     destinations: {
//       azureMonitorMetrics: {
//         name: 'azureMonitorMetrics-default'
//       }
//       logAnalytics: [
//         {
//           name: LawName
//           workspaceResourceId: LawId
//         }
//       ]
//     }
//     streamDeclarations: {}
//   }
// }

//New One
resource DCRLinux 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: 'dcr-ampls-linux'
  location: location
  properties: {
    dataCollectionEndpointId: DCELinux.id
    dataFlows: [
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          'azureMonitorMetrics-default'
        ]
      }
    ]
    dataSources: {
      syslog: [
        {
          name: 'sysLogsDataSource'
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: [
            'alert'
            'audit'
            'auth'
            'authpriv'
            'clock'
            'cron'
            'daemon'
            'ftp'
            'kern'
            'local0'
            'local1'
            'local2'
            'local3'
            'local4'
            'local5'
            'local6'
            'local7'
            'lpr'
            'mail'
            'news'
            'nopri'
            'ntp'
            'syslog'
            'user'
            'uucp'
          ]
          logLevels: [
            'Info'
            'Notice'
            'Warning'
            'Error'
            'Critical'
            'Alert'
            'Emergency'
          ]
        }
      ]
    }
    // description: 'string'
    destinations: {
      azureMonitorMetrics: {
        name: 'azureMonitorMetrics-default'
      }
      logAnalytics: [
        {
          name: LawName
          workspaceResourceId: LawId
        }
      ]
    }
    streamDeclarations: {}
  }
}



// CreateVMモジュールが完了してからexistingで参照したい
resource windowsVM 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: vmName
}


//なぜかDCRの割り当てとDCEの割り当てを別で行う必要がある
resource DCRAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: 'configurationDCR'
  scope: windowsVM
  properties: {
    // dataCollectionEndpointId: DCEWindows.id
    dataCollectionRuleId: DCRLinux.id
    // description: ''
  }
}

resource DCEAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: 'configurationAccessEndpoint'
  scope: windowsVM
  properties: {
    dataCollectionEndpointId: DCELinux.id
    // dataCollectionRuleId: DCRWindows.id
    // description: ''
  }
}

output DCEWindowsId string = DCELinux.id
output DCRWindowsId string = DCRLinux.id
