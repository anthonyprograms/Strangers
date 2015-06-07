//
//  ViewController.m
//  Strangers
//
//  Created by Anthony Williams on 6/6/15.
//  Copyright (c) 2015 Anthony Williams. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) UITextField *nickname;
@property (nonatomic) NSString *storedNickname;
@property (nonatomic) UILabel *storedNicknameLabel;
@property (nonatomic) UILabel *city;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) CLPlacemark *placemark;
@property (nonatomic) NSMutableArray *users;
@property (nonatomic) NSString *matchedUser;
@property (nonatomic) UIButton *startButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:.7 blue:.93 alpha:1];
    
    [self getCityName];
    
    // City Name
    self.city = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 140)];
    self.city.font = [UIFont fontWithName:@"Avenir-Medium" size:32];
    self.city.textColor = [UIColor whiteColor];
    self.city.textAlignment = NSTextAlignmentCenter;
    self.city.text = @"Finding City";
    [self.view addSubview:self.city];
    
    // Nickname
    self.nickname = [[UITextField alloc] initWithFrame:CGRectMake(0, self.city.frame.origin.y+110, self.view.frame.size.width, 70)];
    self.nickname.font = [UIFont fontWithName:@"Avenir-Medium" size:30];
    self.nickname.textColor = [UIColor blackColor];
    self.nickname.autocapitalizationType = NO;
    self.nickname.autocorrectionType = NO;
    self.nickname.placeholder = @"Enter a nickname";
    self.nickname.textAlignment = NSTextAlignmentCenter;
    self.nickname.delegate = self;
    [self.view addSubview:self.nickname];
    
    // Button
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    self.startButton.center = CGPointMake(self.view.frame.size.width/2, self.nickname.frame.origin.y+160);
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    self.startButton.titleLabel.textColor = [UIColor whiteColor];
    self.startButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:40];
    [self.startButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.layer.cornerRadius = self.startButton.frame.size.height/2;
    self.startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startButton.layer.borderWidth = 1.0f;
    self.startButton.layer.masksToBounds = YES;
    [self.view addSubview:self.startButton];
    
    // Stored Nickname - Only displayed after start button has been pressed
    self.storedNicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.city.frame.origin.y+110, self.view.frame.size.width, 70)];
    self.storedNicknameLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:38];
    self.storedNicknameLabel.textColor = [UIColor blackColor];
    self.storedNicknameLabel.textAlignment = NSTextAlignmentCenter;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
}

#pragma mark - Button Methods

-(void)buttonPressed
{
    if (self.nickname.text.length < 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Your nickname must be more than 3 characters long" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (self.nickname.text.length > 11){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Your nickname must be less than 11 characters long" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.city.text isEqualToString:@"Finding City"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"We're currently finding your location, almost got it" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else{
        // Pass variables to chat view controller
        ChatViewController *chatViewController = [[ChatViewController alloc] init];
        
        // Pass variables to chat view controller
        chatViewController.city = self.city.text;
        self.storedNickname = self.nickname.text;
        chatViewController.nickname = self.storedNickname;
        
        // Don't let user change username anymore
        [self.nickname removeFromSuperview];
        self.storedNicknameLabel.text = [NSString stringWithFormat:@"%@", self.storedNickname];
        [self.view addSubview:self.storedNicknameLabel];
        
        // Push Chat View Controller
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}

#pragma mark - Text Field Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nickname){
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)swipe
{
    [self textFieldShouldReturn:self.nickname];
}

#pragma mark - Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"%@", [locations lastObject]);
    
    [self.geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0){
            self.placemark = [placemarks lastObject];
            
            self.city.text = [NSString stringWithFormat:@"%@", self.placemark.locality];
        }
    }];
}

-(void)getCityName
{
    self.manager = [[CLLocationManager alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    self.manager.delegate = self;
    
    if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.manager requestWhenInUseAuthorization];
    }
    [self.manager startUpdatingLocation];
}


@end
