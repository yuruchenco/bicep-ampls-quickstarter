param location string
param subnetId string
param vmName string
param vmAdminUserName string
@secure()
param vmAdminPassword string

// VM variables
var VM_SIZE = 'Standard_B1s'
var VM_IMAGE_PUBLISHER = 'Canonical'
var VM_IMAGE_OFFER = 'UbuntuServer'
var VM_IMAGE_SKU = '18.04-LTS'
var VM_IMAGE_VERSION = 'latest'
var VM_OS_DISK_NAME = 'osdisk-${vmName}'
var VM_OS_DISK_CREATE_OPTION = 'FromImage'
var VM_OS_DISK_CACHING = 'ReadWrite'
var VM_OS_MANAGED_DISK_REDUNDANCY = 'Standard_LRS'
var VM_DATA_DISK_NAME = 'datadisk-${vmName}'
var VM_DATA_DISK_SIZE = 1023
var VM_DATA_DISK_CREATE_OPTION = 'Empty'
var VM_DATA_DISK_CACHING = 'ReadOnly'
var VM_DATA_DISK_LUN = 0
var VM_DATA_MANAGED_DISK_REDUNDANCY = 'StandardSSD_LRS'

var MANAGED_IDENTITY_NAME = 'managedIdentity-${vmName}' 

resource VMCloudNic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'vm-cloud-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}


resource LinuxVm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  properties:{
    hardwareProfile: {
      vmSize: VM_SIZE
    }
    storageProfile: {
      imageReference: {
        publisher: VM_IMAGE_PUBLISHER
        offer: VM_IMAGE_OFFER
        sku: VM_IMAGE_SKU
        version: VM_IMAGE_VERSION
      }
      osDisk: {
        name: VM_OS_DISK_NAME
        createOption: VM_OS_DISK_CREATE_OPTION
        caching: VM_OS_DISK_CACHING
        managedDisk: {
          storageAccountType: VM_OS_MANAGED_DISK_REDUNDANCY
        }
      }
      dataDisks: [
        {
          name: VM_DATA_DISK_NAME
          createOption: VM_DATA_DISK_CREATE_OPTION
          caching: VM_DATA_DISK_CACHING
          diskSizeGB: VM_DATA_DISK_SIZE
          lun: VM_DATA_DISK_LUN
          managedDisk:{
            storageAccountType: VM_DATA_MANAGED_DISK_REDUNDANCY
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: VMCloudNic.id
        }
      ]
    }
    osProfile:{
      computerName: vmName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
  }
}


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: MANAGED_IDENTITY_NAME
  location: location
}

resource linuxAgent 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'AzureMonitorLinuxAgent'
  parent: LinuxVm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': managedIdentity.id
        }
      }
    }
  }
}
output windowsVMId string = LinuxVm.id
output windowsVMName string = LinuxVm.name
// output windowsVM resource = windowsVM

