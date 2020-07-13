//
//  SkyEyeDataConfig.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/17.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "SkyEyeDataConfig.h"

@implementation SkyEyeDataConfig

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
        self.groupArray = [coder decodeObjectForKey:@"groupArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.leftSize forKey:@"leftSize"];
    [coder encodeObject:self.fileName forKey:@"fileName"];
    [coder encodeObject:self.groupArray forKey:@"groupArray"];
}

-(BOOL) containsIndex:(int) index {
    for(NSNumber *iiIndex in self.groupArray) {
        if(iiIndex.intValue == index) {
            return YES;
        }
    }
    return NO;
}
@end
