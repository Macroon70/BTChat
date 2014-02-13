//
//  BTFirstViewController.m
//  BTChat
//
//  Created by Peter on 2013.06.12..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BTFirstViewController.h"
#import "BTMessage.h"

@interface BTFirstViewController ()

@end

@implementation BTFirstViewController

@synthesize chatMessages = _chatMessages;
@synthesize delegate, delegate2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:recognizer];
    self.textMessage.delegate = self;
    _chatMessages = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height - 80) style:UITableViewStylePlain];
    _chatMessages.dataSource = self;
    [self.view addSubview:_chatMessages];
    self.messages = [NSMutableArray array];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing];
    [self.delegate textMessageSender:self data:[NSString stringWithFormat:@"Message sent: %@",textField.text]];
    [self.delegate2 addMessageToAdvertising:textField.text];
    BTMessage *message = [[BTMessage alloc] initWithSender:[[UIDevice alloc] name] message:textField.text status:SENT];
    [self.messages addObject:message];
    [self.chatMessages reloadData];
    self.textMessage.text = nil;
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.detailTextLabel.text = [[self.messages objectAtIndex:indexPath.row] senderName];
    cell.textLabel.text = [[self.messages objectAtIndex:indexPath.row] message];

    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    switch ([[self.messages objectAtIndex:indexPath.row] status]) {
        case SENT:
            cell.contentView.backgroundColor = [UIColor lightGrayColor];
            break;
        case RECEIVED:
            cell.contentView.backgroundColor = [UIColor greenColor];
            break;
        case ARRIVED:
            cell.contentView.backgroundColor = [UIColor whiteColor];
            break;
        case ERROR:
            cell.contentView.backgroundColor = [UIColor redColor];
            break;
    }
    
    return cell;
}
    
-(void)endEditing
{
    [self.textMessage resignFirstResponder];
}

@end
