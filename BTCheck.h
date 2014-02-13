//
//  BTCheck.h
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValidDeviceTypes.h"

@interface BTCheck : NSObject

@property BTStatus btStatus;
@property (strong, nonatomic) NSString* logMessage;

@end
