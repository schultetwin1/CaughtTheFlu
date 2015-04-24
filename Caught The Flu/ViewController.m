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

@property BOOL haveFlu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (![[LibInfected sharedLibInfected] running]) {
        [(LibInfected*)[LibInfected sharedLibInfected] start];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)healthyInfectedChanged:(id)sender {
    if (self.healthyInfectedSegment.selectedSegmentIndex == 2) {
        self.haveFlu = YES;
    } else {
        self.haveFlu = NO;
    }
}

#pragma mark - LibInfectedDelegate

-(void)bleOff {
    
}
-(void)bleOn {
    
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
    
    if (recvdata[0] == 1) {
        self.haveFlu = YES;
    }
}

@end
