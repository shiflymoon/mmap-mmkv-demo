//
//  SkyEyeDataConfig.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/17.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "SkyEyeDataConfig.h"

@implementation PREFIXNAME(DataConfig)

-(instancetype) initWithMaxSize:(int)maxSize fileName:(NSString *)fileName {
    self = [super init];
    if(self) {
        self.leftSize = maxSize;
        self.fileName = fileName;
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if(self) {
        self.leftSize = [coder decodeIntForKey:@"leftSize"];
        self.fileName = [coder decodeObjectForKey:@"fileName"];
        self.sessionGroupArray = [coder decodeObjectForKey:@"sessionGroupArray"];
        self.eventGroupArray = [coder decodeObjectForKey:@"eventGroupArray"];
        self.pageGroupArray = [coder decodeObjectForKey:@"pageGroupArray"];
        self.exceptionGroupArray = [coder decodeObjectForKey:@"exceptionGroupArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.leftSize forKey:@"leftSize"];
    [coder encodeObject:self.fileName forKey:@"fileName"];
    [coder encodeObject:self.sessionGroupArray forKey:@"sessionGroupArray"];
    [coder encodeObject:self.eventGroupArray forKey:@"eventGroupArray"];
    [coder encodeObject:self.pageGroupArray forKey:@"pageGroupArray"];
    [coder encodeObject:self.exceptionGroupArray forKey:@"exceptionGroupArray"];
}

-(BOOL) containsIndex:(int) index type:(SkyEyeStoreDataType)type {
    if(type == SkyEyeStoreDataTypeEvent) {
        for(NSNumber *iiIndex in self.eventGroupArray) {
            if(iiIndex.intValue == index) {
                return YES;
            }
        }
    }else if(type == SkyEyeStoreDataTypePage) {
        for(NSNumber *iiIndex in self.pageGroupArray) {
            if(iiIndex.intValue == index) {
                return YES;
            }
        }
    } else  if(type == SkyEyeStoreDataTypeException) {
        for(NSNumber *iiIndex in self.exceptionGroupArray) {
            if(iiIndex.intValue == index) {
                return YES;
            }
        }
    }else  if(type == SkyEyeStoreDataTypeSession) {
        for(NSNumber *iiIndex in self.sessionGroupArray) {
            if(iiIndex.intValue == index) {
                return YES;
            }
        }
    }
    
    return NO;
}
@end
