//
//  SkyEyePackObject.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "SkyEyePackObject.h"

@implementation SkyEyePackObject

-(instancetype) init {
    self = [super init];
    if(self) {
        _dataArray = [NSMutableArray array];
        _headIndex = -1;
    }
    return self;
}

@end
