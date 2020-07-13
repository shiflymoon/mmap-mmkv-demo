/*
 * Tencent is pleased to support the open source community by making
 * MMKV available.
 *
 * Copyright (C) 2018 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"
#import "PersonObject.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import<sys/sysctl.h> 
#import<mach/mach.h>
#import "AppUsedMemory.h"

@interface AppDelegate ()
{
    NSTimer *_timer;
}
@end

@implementation AppDelegate

#define PREFIXNAME(NAME) SkyEyeAA##NAME


/// 获取当前已用内存: wire_count绑定内存+active_count活跃内存
- (double)getUsedMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
   long long  _wiredMemory_ = vm_page_size * vmStats.wire_count;
   long long  _activeMemory_ = vm_page_size * vmStats.active_count;
   long long   _usedMemory_ = _wiredMemory_ + _activeMemory_;
    return _usedMemory_ / 1024.0/1024.0;
}

- (double)currentAppMemoryUsage {
//    struct mach_task_basic_info info;//有些用的是这个，后面可以测试一下结果
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        //NSLog(@"Memory in use (in bytes): %lld", memoryUsageInByte);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
    }
    return memoryUsageInByte/1024.0/1024.0;
}

- (double) getFreeM2 {
    vm_statistics64_data_t vminfo;

    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vminfo,&count);
    long long physical_memory =  [NSProcessInfo processInfo].physicalMemory;
    unsigned long pagesize = vm_page_size;

   uint64_t total_used_count = (physical_memory /pagesize) - (vminfo.free_count - vminfo.speculative_count) - vminfo.external_page_count - vminfo.purgeable_count;
    uint64_t free_size = ((physical_memory / pagesize) -total_used_count) * pagesize;
    return free_size/1024.0/1024.0;
  
}

double getFreeMemory(){
   if (sizeof(void*) == 4) {
        NSLog(@"32-bit App");
        //32位系统API
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO,(host_info_t)&vmStats, &infoCount);
        if (kernReturn != KERN_SUCCESS) {
            return 0.0;
        }
        return ((vm_page_size * (vmStats.free_count)) / 1024.0f) / 1024.0f;
    } else if (sizeof(void*) == 8) {
        //64位系统API
        NSLog(@"64-bit App");
        vm_statistics64_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics64(mach_host_self(), HOST_VM_INFO,(host_info64_t)&vmStats, &infoCount);
        if (kernReturn != KERN_SUCCESS) {
            return 0.0;
        }
        return ((vm_page_size * (vmStats.free_count)) / 1024.0f) / 1024.0f;
    }
    return 0.0f;
}

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    if (sizeof(void*) == 4) {
        NSLog(@"32-bit App");
        //32位系统API
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO,(host_info_t)&vmStats, &infoCount);
        if (kernReturn != KERN_SUCCESS) {
            return 0.0;
        }
        return ((vm_page_size * (vmStats.free_count + vmStats.inactive_count)) / 1024.0f) / 1024.0f;
    } else if (sizeof(void*) == 8) {
        //64位系统API
        NSLog(@"64-bit App");
        vm_statistics64_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics64(mach_host_self(), HOST_VM_INFO,(host_info64_t)&vmStats, &infoCount);
        if (kernReturn != KERN_SUCCESS) {
            return 0.0;
        }
        return ((vm_page_size * (vmStats.free_count + vmStats.inactive_count)) / 1024.0f) / 1024.0f;
    }
    
  /*vm_statistics_data_t vmStats;
  mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
  kern_return_t kernReturn = host_statistics(mach_host_self(), 
                                             HOST_VM_INFO, 
                                             (host_info_t)&vmStats, 
                                             &infoCount);
  
  if (kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }*/
 vm_statistics_data_t vmStats;
  mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
  kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
  if (kernReturn != KERN_SUCCESS) {
      
      return NSNotFound;
  }
  /*vmStats.active_count +
  vmStats.inactive_count +
  vmStats.wire_count +
  vmStats.free_count*/
  return (((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count))/1024.0)/1024.0;
  
  //return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), 
                                         TASK_BASIC_INFO, 
                                         (task_info_t)&taskInfo, 
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return 0.0;
    }
    
    return (taskInfo.resident_size) / 1024.0 / 1024.0 ;
}

+ (NSUInteger)userMemory {
    int results = 0;
    @try {
        size_t size = sizeof(int);
        int mib[2] = {CTL_HW, HW_USERMEM};
        sysctl(mib, 2, &results, &size, NULL, 0);
    }
    @catch (...) {
    }
    
    return (NSUInteger) results;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _timer = [NSTimer timerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        double aaaa = [self availableMemory];
        double bbbb = [self usedMemory];
        double ccc = getFreeMemory();
        double ddd = [AppDelegate userMemory]/1024.0/1024.0;
       // NSLog(@"memory:%.4f,%.4f,%.4f,%.4f,%.4f",[self getUsedMemory],aaaa,ccc,[self currentAppMemoryUsage],[self getFreeM2]);
        NSLog(@"memory:%.4f,%.4f,%.4f,%.4f,%.4f",[AppUsedMemory getXcodeAppUsedMemory],[AppUsedMemory getXcodeFreeAvalableMemory],[AppUsedMemory getNormalAppUsedMemory],[AppUsedMemory getNormalFreeAvalableMemory],ddd);
    }];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    double aaaa = [self availableMemory];
    double bbbb = [self usedMemory];
	// Override point for customization after application launch.
    int PREFIXNAME(AAA) = 0;
     NSString *networkType = nil;
    
   
       @try {
           CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier * carrier = nil;
           if (@available(iOS 12.1, *)) {
               
               if (info && [info respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
                   
                   NSDictionary *radioDic = [info serviceCurrentRadioAccessTechnology];
                   if (radioDic.allKeys.count) {
                       networkType = [radioDic objectForKey:radioDic.allKeys[0]];
                   }
               }
           }else if (info) {
               networkType = info.currentRadioAccessTechnology;
           }
           
           if (networkType && [networkType hasPrefix:@"CTRadioAccessTechnology"]) {
               //networkType = [networkType substringFromIndex:23];
           }
       }
       @catch (...) {
         
       }

    NSString *name = nil;
       @try {
           CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
           CTCarrier *carrier = nil;
           if (@available(iOS 12.1, *)) {
               
               if (info && [info respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
                   
                   NSDictionary *carrierDic = [info serviceSubscriberCellularProviders];
                   if (carrierDic.allKeys.count) {
                       carrier = [carrierDic objectForKey:carrierDic.allKeys[0]];
                   }
               }
           }else if (info) {
               carrier = info.subscriberCellularProvider;
           }
           if (carrier) {
               name = [carrier carrierName];
           }
       }
       @catch (...) {
       }@finally {
           NSLog(@"aaaa");
       }
   
    NSMutableData * ddtata = [[networkType dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
   NSData *theNewD =  [ddtata subdataWithRange:NSMakeRange(0, 10)];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData: theNewD];
       
  //  NSString *aaaa = [AppDelegate getNetworkOperator ];     
	return YES;
}

+ (NSString *)getNetworkOperator {
    static NSString *networkOperator = nil;
    // __telephony_start__
    if (networkOperator) {
        return networkOperator;
    }
    
    @try {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = nil;
        if (@available(iOS 12.1, *)) {
            
            if (info && [info respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
                
                NSDictionary *carrierDic = [info serviceSubscriberCellularProviders];
                if (carrierDic.allKeys.count) {
                    carrier = [carrierDic objectForKey:carrierDic.allKeys[0]];
                }
            }
        }else if (info) {
            carrier = info.subscriberCellularProvider;
        }
        if (carrier) {
            networkOperator = [NSString stringWithFormat:@"%@%@", [carrier mobileCountryCode], [carrier mobileNetworkCode]];
        }
    }
    @catch (...) {
    }
    
    // __telephony_end__
    
    return networkOperator;
}
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
