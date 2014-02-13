//
//  BTTabBarController.h
//  BTChat
//
//  Created by Peter on 2013.06.13..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTFirstViewController.h"
#import "BTSecondViewController.h"

#import "TransferService.h"

void (^BRLog)(NSString*);

@interface BTTabBarController : UITabBarController
    <CBPeripheralManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, BTFirstViewControllerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;

@property (strong, nonatomic) CBPeripheralManager *peripherialManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableData *receivedData;

@property (strong, nonatomic) BTFirstViewController *fvc;
@property (strong, nonatomic) BTSecondViewController *svc;

@property (nonatomic, readwrite) NSInteger  sendDataIndex;

-(void)addMessageToAdvertising:(NSString *)messageText;

@end
