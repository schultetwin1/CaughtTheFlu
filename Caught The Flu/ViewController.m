//
//  ViewController.m
//  Caught The Flu
//
//  Created by Matt Schulte on 4/24/15.
//  Copyright (c) 2015 Matt Schulte. All rights reserved.
//

#import "ViewController.h"

#import "LibInfected/LibInfected.h"

@interface ViewController () <LibInfectedDelgate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *healthyInfectedSegment;
@property (weak, nonatomic) IBOutlet UILabel *exposedLabel;

@property BOOL haveFlu;
@property NSDate* lastExposure;

@end

@implementation ViewController
- (IBAction)feelingChanged:(id)sender {
    if (self.healthyInfectedSegment.selectedSegmentIndex == 1) {
        self.haveFlu = YES;
    } else {
        self.haveFlu = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ((LibInfected*)[LibInfected sharedLibInfected]).delegate = self;
    self.lastExposure = nil;
    [self.exposedLabel setText:@"NO"];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIUserNotificationType types = UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LibInfectedDelegate

-(void)bleOff {
    [(LibInfected*)[LibInfected sharedLibInfected] stop];
}
-(void)bleOn {
    [(LibInfected*)[LibInfected sharedLibInfected] start];
}

-(CBATTRequest*)receivedReadRequest:(CBATTRequest*) request; {
    const char data[2] = {0,1};
    if (self.haveFlu) {
        request.value = [[NSData alloc] initWithBytes:&data[1] length:1];
    } else {
        request.value = [[NSData alloc] initWithBytes:&data[0] length:1];
    }
    return request;
}

-(void) receivedReadResponse:(NSData*) data peripheralRSSI:(NSNumber*) rssi {
    char recvdata[1];
    [data getBytes:recvdata length:1];
    
    if (recvdata[0] == 1 && !self.haveFlu) {
        self.haveFlu = YES;
        
        self.lastExposure = [[NSDate alloc] init];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE MMM dd, yyyy @ hh:mm a"];
        
        [self.exposedLabel setText:[formatter stringFromDate:self.lastExposure]];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        // Fire in Flu incubation period
        NSDate* incubationDate = [[NSDate alloc] initWithTimeIntervalSinceNow:15];
        notification.alertBody = @"You were infected 3 days ago. Do you have the flu?";
        [notification setAlertTitle:@"Caught the Flu?"];
        [notification setFireDate:incubationDate];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
