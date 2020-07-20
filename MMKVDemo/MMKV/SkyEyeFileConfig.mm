//
//  SkyEyeFileConfig.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/7/13.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "SkyEyeFileConfig.h"
#import "SkyEyeMFKV.h"
#import "SkyEyeScopedLock.hpp"

@interface SkyEyeFileConfig()
{
    PREFIXNAME(MFKV) *_mkv;
    NSRecursiveLock * _lock;
}
@end
@implementation SkyEyeFileConfig

+(instancetype) sharedInstance {
    static SkyEyeFileConfig *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(instancetype) init {
    self = [super init];
    if(self) {
        _lock = [[NSRecursiveLock alloc] init]; 
    }
    return self;
}

-(void) setSkyEyeMMKV:(PREFIXNAME(MFKV) *)mkv {
    PREFIXNAME(CScopedLock) lock(_lock);
    _mkv = mkv;
}

-(void) trim {
    PREFIXNAME(CScopedLock) lock(_lock);
    [_mkv trim];
}

- (nullable id)getObjectOfClass:(Class)cls forType:(SkyEyeConfigType) type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key = getkeyWithType(type);
    return [_mkv getObjectOfClass:cls forKey:key];
}

- (int64_t)getInt64ForType:(SkyEyeConfigType) type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key= getkeyWithType(type);
    return [_mkv getUInt64ForKey:key];
}

-(double) getDoubleForType:(SkyEyeConfigType)type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key = getkeyWithType(type);
    return [_mkv getDoubleForKey:key];
}

-(BOOL) getBoolForType:(SkyEyeConfigType)type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key = getkeyWithType(type);
    return [_mkv getBoolForKey:key];
}

-(void) setConfig:(nullable NSObject<NSCoding> *)object forType:(SkyEyeConfigType) type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key = getkeyWithType(type);
    [_mkv setObject:object forKey:key];
}

-(void) setInt64:(int64_t)value forType:(SkyEyeConfigType) type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key = getkeyWithType(type);
    [_mkv setInt64:value forKey:key];
}

-(void) setBool:(BOOL)value forType:(SkyEyeConfigType)type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key = getkeyWithType(type);
    [_mkv setBool:value forKey:key];
}

-(void) setDouble:(double)value forType:(SkyEyeConfigType)type {
    PREFIXNAME(CScopedLock) lock(_lock);
    NSString *key =  getkeyWithType(type);
    [_mkv setDouble:value forKey:key];
}

#pragma mark - private

static inline NSString * getkeyWithType(SkyEyeConfigType type) {
    NSString *key = [NSString stringWithFormat:@"ct%zd",type];
    return key;
}

@end
