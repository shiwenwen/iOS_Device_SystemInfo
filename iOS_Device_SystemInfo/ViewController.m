//
//  ViewController.m
//  iOS_Device_SystemInfo
//
//  Created by 石文文 on 16/3/26.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "ViewController.h"
#import <mach/mach.h>
#import <sys/mount.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import "MyUUIDNanager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>
@interface ViewController (){
    
    CTTelephonyNetworkInfo *networkInfo;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.唯一标示uuid
    NSString *UUID1 =  [UIDevice currentDevice].identifierForVendor.UUIDString;//可变
    NSString *UUID2 = [MyUUIDNanager getUUID];//卸载后不变
    //2.内存总量
    long long memorySize = [NSProcessInfo processInfo].physicalMemory;
    NSString *memorySizeStr = [self fileSizeToString:memorySize];
    
    //3.当前可用内存
    long long availableMemorySize = [self getAvailableMemorySize];
    NSString *availableMemorySizeStr = [self fileSizeToString:availableMemorySize];
    
    
    //4.获取磁盘总量
    long long DiskSize = [self getTotalDiskSize];
    NSString *DiskSizeStr = [self fileSizeToString:DiskSize];
    
    
    //5.获取可用磁盘量
    long long AvailableDiskSize = [self getAvailableDiskSize];
    NSString *AvailableDiskSizeStr = [self fileSizeToString:AvailableDiskSize];
    
    //6.CPU核心数
    
    
    //7.设备型号
    NSString *deviceModel = [self getCurrentDeviceModel];
    //8.手机MAC地址 iOS7之后不允许
    //当前wifi的信息 MAC和名称
    [self fetchSSIDInfo];
    
    //9.获取sim卡信息
    
    NSArray *simInfo = [self getSimInfo];
    //10 获取IP 外网 内网
    NSString *ip1 = [self whatismyipdotcom];
    NSString *ip2 = [self localWiFiIPAddress];
    
}


#pragma mark -- 当前可用内存
-(long long)getAvailableMemorySize
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
    
    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count));
}

#pragma mark -- 获取磁盘总量
-(long long)getTotalDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
}
#pragma mark --  获取可用磁盘量

-(long long)getAvailableDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}
#pragma mark -- 内存转换

-(NSString *)fileSizeToString:(unsigned long long)fileSize
{
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)
    {
        return @"0 B";
        
    }else if (fileSize < KB)
    {
        return @"< 1 KB";
        
    }else if (fileSize < MB)
    {
        return [NSString stringWithFormat:@"%.1f KB",((CGFloat)fileSize)/KB];
        
    }else if (fileSize < GB)
    {
        return [NSString stringWithFormat:@"%.1f MB",((CGFloat)fileSize)/MB];
        
    }else
    {
        return [NSString stringWithFormat:@"%.1f GB",((CGFloat)fileSize)/GB];
    }
}



/*
 获得设备型号
 */
- (NSString *)getCurrentDeviceModel
{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6S Plus";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6S";
    
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    /*
     if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
     
     if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
     if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
     if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
     if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
     if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
     if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
     if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
     
     if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
     if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
     if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
     if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
     if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
     if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
     
     if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
     if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
     if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
     if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
     if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
     if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
     */
    
    return platform;
}

#pragma mark -- 获取电池状态
-(CGFloat)getBatteryQuantity
{
    return [[UIDevice currentDevice] batteryLevel];
}

#pragma mark --  cpu核心数
- (int )getCPUCores{
    
    unsigned int ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw,ncpu", &ncpu, &len, NULL, 0);
    return ncpu;
    
}
#pragma mark -- sim卡信息
- (NSArray *)getSimInfo{
    networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    //当sim卡更换时
    networkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier){
        
        [[[UIAlertView alloc]initWithTitle:@"" message:@"sim卡更换" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]show];
    };
    //获取sim卡信息
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;

    return @[carrier.carrierName,carrier.mobileCountryCode,carrier.mobileNetworkCode,carrier.isoCountryCode,carrier.allowsVOIP?@"allowsVOIP":@"Don't allowsVOIP"];
//  供应商名称  所在国家编号 供应商网络编号 IOS国家编号 是否支持网络电话
    
}

#pragma mark -- 当前wifi信息
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

#pragma mark -- IP
//这是外网可见的ip地址，如果你在小区的局域网中，那就是小区的，不是局域网的内网地址。
- (NSString *) whatismyipdotcom
{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"https://www.whatismyip.com/my-ip-information/?iref=public-ip"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:1 error:&error];
    return ip ? ip : [error localizedDescription];
    
   
    
}

//这是获取本地wifi的ip地址

// Matt Brown's get WiFi IP addy solution
// Author gave permission to use in Cookbook under cookbook license
// http://mattbsoftware.blogspot.com/2009/04/how-to-get-ip-address-of-iphone-os-v221.html
- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}
#pragma mark -- 


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
