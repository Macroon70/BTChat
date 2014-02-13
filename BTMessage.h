//
//  BTMessage.h
//  BTChat
//
//  Created by Peter on 2013.06.13..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SENT,
    RECEIVED,
    ARRIVED,
    ERROR
} MessageStatus;

@interface BTMessage : NSObject

@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *message;
@property MessageStatus status;

-(id)initWithSender:(NSString*)aSender message:(NSString*)aMessage status:(MessageStatus)aStatus;

@end
