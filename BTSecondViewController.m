//
//  BTSecondViewController.m
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BTSecondViewController.h"

@interface BTSecondViewController ()

@end

@implementation BTSecondViewController

@synthesize logBox = _logBox;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.logBox.editable = NO;
    self.logBox.text = self.textBeforeLoad;
}

-(void)textMessageSender:(BTFirstViewController *)controller data:(NSString *)textMessage
{
    if (!_logBox) {
        self.textBeforeLoad = [self.textBeforeLoad stringByAppendingFormat:@"\n%@", textMessage];
    } else self.logBox.text = [self.logBox.text stringByAppendingFormat:@"\n%@",textMessage];
}

-(void)addMessageToAdvertising:(NSString *)messageText
{
    
}

@end
