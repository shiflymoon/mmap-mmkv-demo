//
//  PersonObject.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonObject : NSObject<NSCoding>
@property(nonatomic,copy) NSString * name;
@property(nonatomic,copy) NSDictionary * dic;
@property(nonatomic,strong) NSMutableArray *dataArray;
@end

NS_ASSUME_NONNULL_END
