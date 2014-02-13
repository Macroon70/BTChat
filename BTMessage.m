//
//  BTMessage.m
//  BTChat
//
//  Created by Peter on 2013.06.13..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BTMessage.h"

@implementation BTMessage

@synthesize senderName = _senderName, message = _message, status = _status;

-(id)initWithSender:(NSString *)aSender message:(NSString *)aMessage status:(MessageStatus)aStatus
{
    if (self == [super init]) {
        _senderName = aSender;
        _message = aMessage;
        _status = aStatus;
    }
    return self;
}

@end
