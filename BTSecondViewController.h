//
//  BTSecondViewController.h
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTFirstViewController.h"

@interface BTSecondViewController : UIViewController <BTFirstViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *logBox;
@property (strong, nonatomic) NSString* textBeforeLoad;

-(void)textMessageSender:(BTFirstViewController *)controller data:(NSString *)textMessage;

@end
