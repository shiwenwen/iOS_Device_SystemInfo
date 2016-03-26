//
//  MyKeyChainManager.h
//  iOS_Device_SystemInfo
//
//  Created by 石文文 on 16/3/26.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyKeyChainManager : NSObject
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;
@end
