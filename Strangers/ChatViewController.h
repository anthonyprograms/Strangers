//
//  ChatViewController.h
//  Strangers
//
//  Created by Anthony Williams on 6/6/15.
//  Copyright (c) 2015 Anthony Williams. All rights reserved.
//

#import "ViewController.h"

@interface ChatViewController : ViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) NSString *city;
@property (nonatomic) NSString *nickname;
@property (nonatomic) NSString *matchedUser;

@end
