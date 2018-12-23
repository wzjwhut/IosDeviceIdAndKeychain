//
//  ViewController.m
//  MyDeviceId
//
//  Created by wzj on 2018/12/23.
//  Copyright © 2018年 wzj. All rights reserved.
//

#import "ViewController.h"
#import <Security/Security.h>
#import "KeychainUtl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"device id: %@", deviceId);
    [KeychainUtil add:@"idfv" data:deviceId];
    NSString* value = [KeychainUtil read:@"idfv"];
    NSLog(@"device id = %@", value);
    [KeychainUtil remove:@"idfv"];
    value = [KeychainUtil read:@"idfv"];
    NSLog(@"device id = %@", value);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
