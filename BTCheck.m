//
//  BTCheck.m
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BTCheck.h"
#import "UIDeviceHardware.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation BTCheck

@synthesize btStatus = _btStatus;
@synthesize logMessage = _logMessage;

-(id)init
{
    if (self == [super init]) {
        [self checkBlutoothAvaliability];
    }
    return self;
}

-(void)checkBlutoothAvaliability
{
    // First, determine the device
    UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
    if ([device checkPlatformVersionFromArray:VALID_DEVICE_TYPES]) {
        _btStatus = READY;
        _logMessage = READY_TEXT;
    } else {
        _btStatus = DEVICE_ERROR;
        _logMessage = DEVICE_ERROR_TEXT;
    }
    
    // If device version is applied, chek bluetooth state
    // First BT use the system show alert to turn on
}

@end
