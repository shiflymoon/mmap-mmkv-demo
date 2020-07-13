//
//  AppUsedMemory.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/23.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUsedMemory : NSObject
//获取应用占用内存大小，采用xcode一致算法,返回MB
+(double) getXcodeAppUsedMemory;
//获取可用内存大小，采用Xcode一致算法，返回MB
+(double) getXcodeFreeAvalableMemory;

//正常获取可用内存大小，和xcode误差在100M以内
+(double) getNormalFreeAvalableMemory;
//正常获取可用内存大小，和xcode误差较大
+(double) getNormalAppUsedMemory;
@end

NS_ASSUME_NONNULL_END
