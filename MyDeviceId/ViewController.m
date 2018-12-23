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

static NSString *const accessItem = @"com.wzj.MyDeviceId";

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"device id: %@", deviceId);
    [ViewController addKeychainData:deviceId forKey:@"idfv"];
    NSString* value = [ViewController readForkey:@"idfv"];
    NSLog(@"device id = %@", value);
    
}
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)addKeychainData:(id)data forKey:(NSString *)key{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:accessItem forKey:(id)kSecAttrAccessGroup];
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    OSStatus status;
    if( (status = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL)) != noErr){
        NSLog(@"SecItemAdd error: %d", status);
    }
}

+ (void)deleteWithService:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

+ (id)readForkey:(NSString *)key {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    OSStatus status;
    if ((status = SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData)) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", key, e);
        } @finally {
        }
    }else{
        NSLog(@"SecItemCopyMatching error: %d", status);
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
