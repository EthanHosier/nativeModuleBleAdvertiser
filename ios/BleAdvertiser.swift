//
//  BleAdvertiser.swift
//  btTestNativeModules
//
//  Created by Owner on 23/02/2023.
//


//######### TODO: add error cases to failed broacasting possibility - maybe make use of callback?? #######
import Foundation
import CoreBluetooth

@objc(BleAdvertiser)
class BleAdvertiser: RCTEventEmitter, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
  
  private var peripheralManager: CBPeripheralManager?
  private var characteristic: CBMutableCharacteristic?
  private var service: CBMutableService?
  private var centralManager: CBCentralManager?
  
  //TODO: MAKE THIS RETURN A PROMISE IF SUCCEEDS
  @objc func startBroadcasting(_ serviceId: String, characteristicId: String) {
        
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
      sendEvent(withName: "BroadcastingStatus", body: ["\(service!)"])

      // Check if peripheral manager is available
      guard let peripheralManager = peripheralManager else {
          sendEvent(withName: "BroadcastingStatus", body: ["Failed to start broadcasting - peripheral manager not available"])
          return
      }
      
      // Check if service is already being advertised
      if peripheralManager.isAdvertising {
          sendEvent(withName: "BroadcastingStatus", body: ["Failed to start broadcasting - service already being advertised"])
          return
      }
      
      // Check if peripheral manager is powered on
      guard peripheralManager.state == .poweredOn else {
          sendEvent(withName: "BroadcastingStatus", body: ["Failed to start broadcasting - peripheral manager is not powered on"])
          return
      }
      
      // Start broadcasting the service
      peripheralManager.add(service!)
      peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])

      sendEvent(withName: "BroadcastingStatus", body: ["Started Broadcasting"])
  }
  
  @objc func initialize(){
    self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
  
  @objc func stopBroadcasting() {
      // Stop broadcasting the service
      peripheralManager?.stopAdvertising()
      peripheralManager?.remove(service!)
    
      sendEvent(withName: "BroadcastingStatus", body: ["Stopped Broadcasting"])

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
      return ["BroadcastingStatus", "BleStatus"];
  }
  
  func peripheralManagerDidStartAdvertising(
      _ peripheral: CBPeripheralManager,
      error: Error?
  ){
    sendEvent(withName: "BroadcastingStatus", body: ["Error Broadcasting: \(error.debugDescription)"])
  }
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    print("YEAHHH")
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
