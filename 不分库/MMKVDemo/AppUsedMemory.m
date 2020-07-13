//
//  AppUsedMemory.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/23.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "AppUsedMemory.h"
#import<sys/sysctl.h> 
#import<mach/mach.h>

@implementation AppUsedMemory
//获取应用占用内存大小，采用xcode一致算法
+(double) getXcodeAppUsedMemory {
    uint64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn != KERN_SUCCESS) {
        return 0;
    } 
     memoryUsageInByte = vmInfo.phys_footprint;
    return memoryUsageInByte/1024.0/1024.0;
}

//获取可用内存大小，采用Xcode一致算法
+(double) getXcodeFreeAvalableMemory {
    if(sizeof(void *) == 4) {
        vm_statistics_data_t vminfo;
        
        mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
        
        host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vminfo,&count);
        unsigned long long physical_memory =  [NSProcessInfo processInfo].physicalMemory;
        unsigned long pagesize = vm_page_size;
        
        uint64_t total_used_count = (physical_memory /pagesize) - (vminfo.free_count - vminfo.speculative_count)  - vminfo.purgeable_count;
        uint64_t free_size = ((physical_memory / pagesize) -total_used_count) * pagesize;
        return free_size/1024.0/1024.0;
    }else if(sizeof(void *) >= 8) {
        vm_statistics64_data_t vminfo;
        
        mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
        
        host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vminfo,&count);
        unsigned long long physical_memory =  [NSProcessInfo processInfo].physicalMemory;
        unsigned long pagesize = vm_page_size;
        
        uint64_t total_used_count = (physical_memory /pagesize) - (vminfo.free_count - vminfo.speculative_count) - vminfo.external_page_count - vminfo.purgeable_count;
        uint64_t free_size = ((physical_memory / pagesize) -total_used_count) * pagesize;
        return free_size/1024.0/1024.0;
    }
    return 0.0;
}

+(double) getNormalFreeAvalableMemory {
    if (sizeof(void*) == 4) {
        //32位系统API
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO,(host_info_t)&vmStats, &infoCount);
        if (kernReturn != KERN_SUCCESS) {
            return 0.0;
        }
        return ((vm_page_size * (vmStats.free_count + vmStats.inactive_count)) / 1024.0f) / 1024.0f;
    } else if (sizeof(void*) >= 8) {
        //64位系统API
        vm_statistics64_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics64(mach_host_self(), HOST_VM_INFO,(host_info64_t)&vmStats, &infoCount);
        if (kernReturn != KERN_SUCCESS) {
            return 0.0;
        }
        return ((vm_page_size * (vmStats.free_count + vmStats.inactive_count)) / 1024.0f) / 1024.0f;
    }
    return 0.0;
}

+(double) getNormalAppUsedMemory {
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
@end
