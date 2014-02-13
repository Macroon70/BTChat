//
//  ValidDeviceTypes.h
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#ifndef BTChat_ValidDeviceTypes_h
#define BTChat_ValidDeviceTypes_h

typedef enum {
    READY,
    DEVICE_ERROR,
    BT_ERROR
} BTStatus;

#define READY_TEXT          @"Bluetooth 4 is ready and online"
#define DEVICE_ERROR_TEXT   @"This app is works only on devices with Bluetooth 4 technology"
#define BT_ERROR_TEXT       @"Bluetooth state unknown"

#define VALID_DEVICE_TYPES @[ @"iPhone4,1",@"iPhone5,1",@"iPhone5,2",@"iPad3,4",@"iPad3,5",@"iPad3,6" ]

#endif
