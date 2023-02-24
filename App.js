import { View, Text, TouchableOpacity } from 'react-native'
import React, { useEffect } from 'react'
import { NativeModules, NativeEventEmitter} from 'react-native'
import { BleManager } from 'react-native-ble-plx'

const BleAdvertiser = NativeModules.BleAdvertiser;
BleAdvertiser.initialize()
const BleAdvertiserEvents = new NativeEventEmitter(NativeModules.BleAdvertiser);

const bleCentral = new BleManager();

const SERVICE = "8896d8ba-29ff-4a49-8e3e-356e9bc106fa" //matching btTest2
const CHARACTERISTIC = "c5ac1ec8-b3b2-11ed-afa1-0242ac120002"

/*
TODO:
1. TRY THE "peripheralManagerDidStartAdvertising(_:error:)" https://developer.apple.com/documentation/corebluetooth/cbperipheralmanagerdelegate/1393321-peripheralmanagerdidstartadverti    sendEvent("..", error ?? "success")
2. Check all the bluetooth permissions are correct
3. Check the code given (by chat gpt) matches the "send data w/  ble" in swift docs
4. Check that am actually broadcasting signal correctly (check that device appears at all, then that formatted correctly etc)  - use bluetooth sniffer app etc??
*/
console.log(BleAdvertiser)
const App = () => {

    useEffect(() => {
        BleAdvertiserEvents.addListener("BleStatus", console.log)
        BleAdvertiserEvents.addListener("BroadcastingStatus", console.log)
        
        return () => {
          BleAdvertiserEvents.removeAllListeners();
        }
    },[])

    const startAdvertising = () => {
      BleAdvertiser.startBroadcasting(SERVICE, CHARACTERISTIC);
    }

    const stopAdvertising = () => {
      BleAdvertiser.stopBroadcasting();
    }

    const handleCentral = () => {
      console.log("ACTING AS LISTENER")
      scanForDevices();
  }

  const scanForDevices = async () => {

      bleCentral.startDeviceScan([SERVICE], null, async (error, device) => {
          if (error) {
              console.log(error)
              return;
          }

          if (device) {
            /*console.log(device)
              console.log(device)
              return;
            */


              try{
                await device.connect()
              } catch (e){
                console.error("error connecting")
                return;
              }

              try{
                await device.discoverAllServicesAndCharacteristics();
              } catch (e){
                console.error("error discovering services and characteristics")
                await device.cancelConnection();
                return;
              }
              
              try{
              const services = await device.services();
              //console.log(services)
            } catch (e) {
              console.log("Error finding services")
              await device.cancelConnection();
              return
            }
            
            try{
              const characteristics = await device.characteristicsForService(SERVICE);
              console.log(characteristics[0].uuid)
            } catch (e){
              console.error(e)
            }
              //characteristics?.forEach((chr) => console.log(chr.uuid));
              
            await device.cancelConnection();


            }
          
      })



  }

  return (
    <View style={{flex:1, justifyContent: "center", alignItems:"center"}}>

      <TouchableOpacity style={{marginTop:20}} onPress={startAdvertising}><Text>Start Advertisings</Text></TouchableOpacity>
      <TouchableOpacity style={{marginTop:20}} onPress={stopAdvertising}><Text>Stop Advertising</Text></TouchableOpacity>
      <TouchableOpacity style={{marginTop:20}} onPress={handleCentral}><Text>Act as central</Text></TouchableOpacity>

    </View>
  )
}

export default App