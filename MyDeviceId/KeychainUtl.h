//
//  KeychainUtl.h
//  MyDeviceId
//
//  Created by wzj on 2018/12/23.
//  Copyright © 2018年 wzj. All rights reserved.
//

#ifndef KeychainUtl_h
#define KeychainUtl_h

#import <Security/Security.h>

@interface KeychainUtil : NSObject

@end

@implementation KeychainUtil
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
    NSString* bundlerId = [[NSBundle mainBundle] bundleIdentifier];
    [keychainQuery setObject:bundlerId forKey:(id)kSecAttrAccessGroup];
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

@end


#endif /* KeychainUtl_h */
