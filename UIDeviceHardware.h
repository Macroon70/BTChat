//
//  UIDeviceHardware.h
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDeviceHardware : NSObject

-(NSString*)platform;
-(NSString*)platformString;
-(BOOL)checkPlatformVersionFromArray:(NSArray*)deviceList;

@end
