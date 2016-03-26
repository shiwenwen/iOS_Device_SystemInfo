//
//  MyUUIDNanager.h
//  iOS_Device_SystemInfo
//
//  Created by 石文文 on 16/3/26.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyUUIDNanager : NSObject
+(void)saveUUID:(NSString *)uuid;

+(NSString *)getUUID;

+(void)deleteUUID;
@end
