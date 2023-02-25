//
//  BleAdvertiser.swift
//  btTestNativeModules
//
//  Created by Owner on 23/02/2023.
//



import Foundation
import CoreBluetooth

@objc(BleAdvertiser)
class BleAdvertiser: RCTEventEmitter, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
  
  private var peripheralManager: CBPeripheralManager?
  private var characteristic: CBMutableCharacteristic?
  private var service: CBMutableService?
  private var centralManager: CBCentralManager?
  
  override init(){
    super.init()
    initialize()
  }
  
  //TODO: MAKE THIS RETURN A PROMISE IF SUCCEEDS
  @objc func startAdvertising(_ serviceId: String, characteristicId: String) {
        
      // Check if peripheral manager is available
      guard let peripheralManager = peripheralManager else {
          sendEvent(withName: "AdvertisingStatus", body: ["Error"])
          print("Failed to start advertising - peripheral manager not available")
          return
      }
    
      // Check if service is already being advertised
      if peripheralManager.isAdvertising {
          sendEvent(withName: "AdvertisingStatus", body: ["Already Advertising"])
          print("Failed to start advertising - service already being advertised")
          return
      }
    
      // Create a service UUID and characteristic UUID
      let serviceUUID = CBUUID(string: serviceId)
      let characteristicUUID = CBUUID(string: characteristicId)
      
      
      // Create the service and characteristic
      characteristic = CBMutableCharacteristic(type: characteristicUUID,
                                               properties: [.read, .write],
                                                value: nil,
                                                permissions: [.readable, .writeable])
      service = CBMutableService(type: serviceUUID, primary: true)
      service?.characteristics = [characteristic!]
      //sendEvent(withName: "AdvertisingStatus", body: ["\(service!)"])

      
      
      
      
      // Check if peripheral manager is powered on
      guard peripheralManager.state == .poweredOn else {
        sendEvent(withName: "AdvertisingStatus", body: ["Error"])
        print("Failed to start advertising - peripheral manager is not powered on")
          return
      }
      
      // Start advertising the service
      peripheralManager.add(service!)
      peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])

      
  }
  
  func initialize(){
    self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
  
  @objc func stopAdvertising() {
      // Stop advertising the service
      peripheralManager?.stopAdvertising()
      peripheralManager?.remove(service!)
    
      sendEvent(withName: "AdvertisingStatus", body: ["Stopped Advertising"])

  }
  


  @objc
  override static func requiresMainQueueSetup() -> Bool{
    return true;
  }

//delete this??
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    return
  }
  
  override func supportedEvents() -> [String]! {
      return ["AdvertisingStatus", "BleStatus"];
  }
  
  func peripheralManagerDidStartAdvertising(
      _ peripheral: CBPeripheralManager,
      error: Error?
  ){
    
    if let error = error{
      sendEvent(withName: "AdvertisingStatus", body: ["Error"])
      print("Advertising failed with \(error.localizedDescription)")
      return
    }
    sendEvent(withName: "AdvertisingStatus", body: ["Started Advertising"])
  }
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .unknown:
      sendEvent(withName: "BleStatus", body: ["unknown"])
    case .unsupported:
      sendEvent(withName: "BleStatus", body: ["unsupported"])
    case .unauthorized:
      sendEvent(withName: "BleStatus", body: ["unauthorized"])
    case .resetting:
      sendEvent(withName: "BleStatus", body: ["resetting"])
    case .poweredOff:
      sendEvent(withName: "BleStatus", body: ["off"])
    case .poweredOn:
      sendEvent(withName: "BleStatus", body: ["on"])
    @unknown default:
      sendEvent(withName: "BleStatus", body: ["#unknown"])
    }
  }
  
  
  
}
