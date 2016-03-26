//
//  MyUUIDNanager.m
//  iOS_Device_SystemInfo
//
//  Created by 石文文 on 16/3/26.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "MyUUIDNanager.h"
#import "MyKeyChainManager.h"
#import <UIKit/UIKit.h>
@implementation MyUUIDNanager
static NSString * const KEY_IN_KEYCHAIN = @"com.bestudent.uuid";


+(void)saveUUID:(NSString *)uuid{
    if (uuid && uuid.length > 0) {
        [MyKeyChainManager save:KEY_IN_KEYCHAIN data:uuid];
    }
}


+(NSString *)getUUID{
    //先获取keychain里面的UUID字段，看是否存在
    NSString *uuid = (NSString *)[MyKeyChainManager load:KEY_IN_KEYCHAIN];
    
    //如果不存在则为首次获取UUID，所以获取保存。
    if (!uuid || uuid.length == 0) {
        
        uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
        
        [self saveUUID:uuid];
        

    }
    
    return uuid;
}



+(void)deleteUUID{
    [MyKeyChainManager delete:KEY_IN_KEYCHAIN];
}

@end
