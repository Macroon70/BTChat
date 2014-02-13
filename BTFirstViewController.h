//
//  BTFirstViewController.h
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTFirstViewController;
@protocol BTFirstViewControllerDelegate <NSObject>

@optional
-(void)textMessageSender:(BTFirstViewController*)controller data:(NSString*)textMessage;
-(void)addMessageToAdvertising:(NSString*)messageText;

@end

@interface BTFirstViewController : UIViewController
    <UITextFieldDelegate, UITableViewDataSource> {
        __weak id<BTFirstViewControllerDelegate> delegate;
        __weak id<BTFirstViewControllerDelegate> delegate2;
}

@property (strong, nonatomic) UITableView* chatMessages;
@property (weak, nonatomic) IBOutlet UITextField* textMessage;
@property (weak, nonatomic) id<BTFirstViewControllerDelegate> delegate;
@property (weak, nonatomic) id<BTFirstViewControllerDelegate> delegate2;
@property (strong, nonatomic) NSMutableArray* messages;

@end
