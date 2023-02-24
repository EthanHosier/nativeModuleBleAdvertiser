//
//  BleAdvertiser.m
//  btTestNativeModules
//
//  Created by Owner on 23/02/2023.
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(BleAdvertiser, RCTEventEmitter)

RCT_EXTERN_METHOD(startBroadcasting: (NSString *)serviceId characteristicId: (NSString *)characteristicId)
RCT_EXTERN_METHOD(stopBroadcasting)
RCT_EXTERN_METHOD(initialize)

@end
