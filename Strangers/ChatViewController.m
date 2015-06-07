//
//  ChatViewController.m
//  Strangers
//
//  Created by Anthony Williams on 6/6/15.
//  Copyright (c) 2015 Anthony Williams. All rights reserved.
//

#import "ChatViewController.h"
#import <Firebase/Firebase.h>

@interface ChatViewController ()

@property (nonatomic) UITextField *typeField;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSMutableArray *users;
@property (nonatomic) NSString *firstUser;
@property (nonatomic) NSString *secondUser;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
//    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:.7 blue:.93 alpha:1];
    
    self.messages = [[NSMutableArray alloc] init];
    
    // End Button
    UIButton *endButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 40)];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    [endButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    endButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:24];
//    [endButton setBackgroundColor:[UIColor lightGrayColor]];
    [endButton addTarget:self action:@selector(endButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:endButton];
    
    // TextField
    self.typeField = [[UITextField alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height-60, self.view.frame.size.width-10, 60)];
    self.typeField.placeholder = @"Start Typing Here";
    self.typeField.textColor = [UIColor blackColor];
    self.typeField.font = [UIFont fontWithName:@"Avenir-Medium" size:22];
    self.typeField.delegate = self;
    self.typeField.returnKeyType = UIReturnKeySend;
    [self.view addSubview:self.typeField];
    
    // Table View
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height-140)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];
    
    
    // On Swipe Down hide keyboard
    UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownGestureRecognizer];
    
    // Access Firebase to find the messages
    Firebase *fbchat = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"strangers.firebaseio.com/chats/%@", self.city]];
    [fbchat observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.hasChildren){
            self.messages = [[NSMutableArray alloc] initWithArray:snapshot.value];
        }
        else {
            self.messages = [[NSMutableArray alloc] initWithObjects:nil];
            [fbchat setValue:self.messages];
        }
        [self.tableView reloadData];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)endButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonPressed
{
    // Update Array
    [self.messages addObject:[NSString stringWithFormat:@"%@: %@", self.nickname, self.typeField.text]];
    self.typeField.text = @"";
    
    // Send to Firebase
    Firebase *fbchat = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"strangers.firebaseio.com/chats/%@", self.city]];
    [fbchat setValue:self.messages];
}

- (void)swipeDown:(UIGestureRecognizer*)recognizer
{
    [self textFieldDidEndEditing:self.typeField];
}

#pragma mark - UITableView Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.messages objectAtIndex:indexPath.row]];
    cell.textLabel.numberOfLines = 2;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - TextField Editing

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.typeField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.typeField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.typeField.frame = CGRectMake(self.typeField.frame.origin.x, self.view.frame.size.height/2, self.typeField.frame.size.width, self.typeField.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height/2-60);
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.typeField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.typeField.frame = CGRectMake(self.typeField.frame.origin.x, self.view.frame.size.height-60, self.typeField.frame.size.width, self.typeField.frame.size.height);
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height-140);
        [UIView commitAnimations];
        [self sendButtonPressed];
    }
}

@end
