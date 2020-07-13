//
//  PersonObject.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "PersonObject.h"

@implementation PersonObject

-(instancetype) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if(self) {
       self.name = [coder decodeObjectForKey:@"name"];
       self.dic =  [coder decodeObjectForKey:@"dic"];
        self.dataArray = [coder decodeObjectForKey:@"dataArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_dic forKey:@"dic"];
    [coder encodeObject:_dataArray forKey:@"dataArray"];
}
@end
