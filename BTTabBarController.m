//
//  BTTabBarController.m
//  BTChat
//
//  Created by Peter on 2013.06.13..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BTTabBarController.h"
#import "BTCheck.h"
#import "BTMessage.h"

@interface BTTabBarController ()

@end

@implementation BTTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

	
    // Do any additional setup after loading the view.

    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _peripherialManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _peripherialManager.delegate = self;
    _data = [NSMutableArray array];
    _receivedData = [[NSMutableData alloc] init];
    
    _svc = [self.viewControllers objectAtIndex:1];
    _fvc = [self.viewControllers objectAtIndex:0];
    _fvc.delegate = _svc;
    _fvc.delegate2 = self;
    BTCheck *check = [[BTCheck alloc] init];
    _svc.textBeforeLoad = check.logMessage;
    BRLog = ^(NSString* logText) {
        NSLog(@"%@", logText);
        [_svc textMessageSender:nil data:logText];
    };


}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.peripherialManager stopAdvertising];
    [self.centralManager stopScan];
    BRLog(@"Central and Advertising stopped");
    [super viewWillDisappear:animated];
}


#pragma mark - Central Methods

// Ha változik a central object állapota CBCentralManagerState
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    BRLog([NSString stringWithFormat:@"Central state %d",(CBCentralManagerState)central.state]);
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    [self scan];
}

// Ha a central kapcsolódott egy eszközhöz
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    BRLog([NSString stringWithFormat:@"Connected to %@ peripheral",peripheral.name]);
    
    // Leállítjuk a keresést amíg élő a kapcsolat
    //[self.centralManager stopScan];
    //BRLog(@"Scanning stopped");
    
    self.receivedData.length = 0;
    
    // Megnézzük, hogy ugyanazt a SERVICE_UUID-t használja-e az eszköz
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]]];

    
}

// Ha a central lekapcsolódott az elözőleg kapcsolódott eszközről
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BRLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
    // Újraindítjuk a keresést
    [self scan];
}

// Ha central talált egy eszkőzt
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Ha a jel nem esik a megfelelő tartományba, akkor nem folytatjuk tovább a folyamatot
    //if (RSSI.integerValue > RANGE_MAX) return;
    //if (RSSI.integerValue < RANGE_MIN) return;
    
    BRLog([NSString stringWithFormat:@"Discovered %@ at %@", peripheral.name, RSSI]);
    
    if (self.discoveredPeripheral != peripheral) {
        self.discoveredPeripheral = peripheral;
        
        BRLog([NSString stringWithFormat:@"Connecting to peripheral %@", peripheral]);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

// Ha hiba történt a kapcsolódás közben
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BRLog([NSString stringWithFormat:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]]);
    [self cleanup];
}

// A kapcsolódott eszközök listája
-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    BRLog([NSString stringWithFormat:@"Connected Peripherals list:%@",peripherals]);
}

// A feltárt eszközök listája
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    BRLog([NSString stringWithFormat:@"Possible Peripherals list:%@",peripherals]);
}

// adatok alaphelyzetbe állítása
-(void)cleanup
{
    
    BRLog(@"Cleanup");
    if (!self.discoveredPeripheral.isConnected) return;
    
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BR_TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    BRLog(@"Cleanup at the end");
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    self.discoveredPeripheral = nil;
}

// keresés elindítása
-(void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    BRLog(@"Scanning started");
}


#pragma mark - connected peripheral delegates

// A kapcsolódott eszköz szervízében megnézi az egyéni UUID-t
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error discovering services: %@", [error localizedDescription]]);
        [self cleanup];
        return;
    }
    
    BRLog(@"Discovering services");
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BR_TRANSFER_CHARACTERISTIC_UUID]]
                                 forService:service];
    }
    
}

// A kapcsolódott eszköz karakterisztikájn végigmegy, és ha talál benne egyezést az UUID-re, akkor Notify értékre állítja
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error discovering characteristics: %@", [error localizedDescription]]);
        [self cleanup];
        return;
    }
    
    BRLog(@"Discovering characteristics");
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BR_TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error discovering Descriptor: %@", [error localizedDescription]]);
        [self cleanup];
        return;
    }
    BRLog(@"Discovering Descriptors");
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error discovering Included services: %@", [error localizedDescription]]);
        [self cleanup];
        return;
    }
    BRLog(@"Discovering included services");
}

// Ha változik a notify state
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error changing notification state: %@", [error localizedDescription]]);
    }

    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:BR_TRANSFER_CHARACTERISTIC_UUID]]) return;
        
    if (characteristic.isNotifying) {
        BRLog([NSString stringWithFormat:@"Notification began on %@", characteristic]);
    } else {
        BRLog([NSString stringWithFormat:@"Notification stopped on %@. Disconnecting", characteristic]);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

// Ha új characteristic érték van
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error update value for characteristic: %@",[error localizedDescription]]);
        return;
    }
    
    BRLog(@"Update value for Characteristic");
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if ([stringFromData isEqualToString:@"EOM"]) {
        BTMessage *message = [[BTMessage alloc] initWithSender:peripheral.name
                                                       message:[[NSString alloc] initWithData:self.receivedData
                                                                                     encoding:NSUTF8StringEncoding]
                                                        status:ARRIVED];
        [_fvc.messages addObject:message];
        [_fvc.chatMessages reloadData];
        
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    [self.receivedData appendData:characteristic.value];
    
    BRLog([NSString stringWithFormat:@"Received: %@", stringFromData]);
}


#pragma mark - Peripherial Methods

// Elkezdődött az adatküldés folyamata
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        BRLog([NSString stringWithFormat:@"Error start advertising: %@", [error localizedDescription]]);
        BRLog(@"Start again");
        [self.peripherialManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]] }];
        int index = 0;
        int index2 = -1;
        for (BTMessage *message in _fvc.messages) {
            if ([message.message isEqualToString:[[NSString alloc] initWithData:[self.data objectAtIndex:0]
                                                                       encoding:NSUTF8StringEncoding]]) {
                index2 = index;
            }
            index++;
        }
        if (index2 != -1) {
            [[_fvc.messages objectAtIndex:index2] setStatus:RECEIVED];
            [_fvc.chatMessages reloadData];
        }
    }
    BRLog(@"Advertising started");
}

// State változik
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        BRLog(@"PeripheralManager not powered on");
        return;
    }
    
    BRLog(@"PeripheralManager powered on.");
    
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BR_TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    transferService.characteristics = @[self.transferCharacteristic];
    [self.peripherialManager addService:transferService];
}

// Központ feliratkozott a fogadásra
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    BRLog(@"Central subscribed to characteristics");
    
    self.sendDataIndex = 0;
    [self sendData];
}

// Központ leíratkozott
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    BRLog(@"Central unsubscribed from characteristic");
}

// Send data
-(void)sendData
{
    
    
    if ([self.data count] == 0) {
        //[self.peripherialManager stopAdvertising];
        return;
    }
    
    static BOOL sendingEOM = NO;

    NSLog(@"%c",sendingEOM);
    
    if (sendingEOM) {
    
        BOOL didSend = [self.peripherialManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding]
                                          forCharacteristic:self.transferCharacteristic
                                       onSubscribedCentrals:nil];
        if (didSend) {
            sendingEOM = NO;
            BRLog(@"Sent: EOM1");
            int index = 0;
            int index2 = -1;
            for (BTMessage *message in _fvc.messages) {
                if ([message.message isEqualToString:[[NSString alloc] initWithData:[self.data objectAtIndex:0]
                                                                           encoding:NSUTF8StringEncoding]]) {
                    index2 = index;
                }
                index++;
            }
            if (index2 != -1) {
                [[_fvc.messages objectAtIndex:index2] setStatus:RECEIVED];
                [_fvc.chatMessages reloadData];
            }
            
            [self.data removeObjectAtIndex:0];
            if ([self.data count] == 0) {
                [self.peripherialManager stopAdvertising];
                //[self scan];
            } else {
                self.sendDataIndex = 0;
                [_peripherialManager stopAdvertising];
                [self.peripherialManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]] }];
                [self sendData];
            }
        }
        return;
    }
    
    NSData *dataToSend = [NSData dataWithData:[self.data objectAtIndex:0]];
    
    if (self.sendDataIndex >= dataToSend.length) return;
    
    BOOL didSend = YES;

    
    while (didSend) {
        NSInteger ammountToSend = dataToSend.length - self.sendDataIndex;
        
        if (ammountToSend > NOTIFY_MTU) ammountToSend = NOTIFY_MTU;
        
        NSData *chunk = [NSData dataWithBytes:dataToSend.bytes+self.sendDataIndex length:ammountToSend];
        
        didSend = [self.peripherialManager updateValue:chunk
                                     forCharacteristic:self.transferCharacteristic
                                  onSubscribedCentrals:nil];
        
        if (!didSend) return;
        NSString *stringFromData = [[NSString alloc] initWithData:chunk
                                                         encoding:NSUTF8StringEncoding];
        BRLog([NSString stringWithFormat:@"Sent: %@",stringFromData]);

        self.sendDataIndex += ammountToSend;

        
        if (self.sendDataIndex >= dataToSend.length) {
            sendingEOM = YES;
            
            BOOL eomSent = [self.peripherialManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding]
                                              forCharacteristic:self.transferCharacteristic
                                           onSubscribedCentrals:nil];
            
            if (eomSent) {
                sendingEOM = NO;
                BRLog(@"Sent EOM2");
                [self.data removeObjectAtIndex:0];
                if ([self.data count] == 0) {
                    [self.peripherialManager stopAdvertising];
                } else {
                    self.sendDataIndex = 0;
                    [_peripherialManager stopAdvertising];
                    [self.peripherialManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]] }];
                    [self sendData];
                }
            }
            
            return;
        }

        
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        int index = 0;
        int index2 = -1;
        for (BTMessage *message in _fvc.messages) {
            if ([message.message isEqualToString:[[NSString alloc] initWithData:[self.data objectAtIndex:0]
                                                                       encoding:NSUTF8StringEncoding]]) {
                index2 = index;
            }
            index++;
        }
        if (index2 != -1) {
            [[_fvc.messages objectAtIndex:index2] setStatus:ERROR];
            [_fvc.chatMessages reloadData];
        }
    }
    BRLog(@"Service added");
}

-(void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    BRLog(@"Ready to send data");
    [self sendData];
}

#pragma mark - BTFirstViewControllerDelegate methods

-(void)addMessageToAdvertising:(NSString *)messageText
{
    BRLog( [NSString stringWithFormat:@"Adding to PeripherialManager: %@",messageText] );
    [_data addObject:[messageText dataUsingEncoding:NSUTF8StringEncoding]];
    if (![_peripherialManager isAdvertising]) {
    //if (_peripherialManager.state == CBPeripheralManagerStatePoweredOff) {
    [self.peripherialManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:BR_TRANSFER_SERVICE_UUID]] }];
    }
}

-(void)textMessageSender:(BTFirstViewController *)controller data:(NSString *)textMessage
{
    
}

@end
