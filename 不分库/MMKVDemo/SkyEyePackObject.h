//
//  SkyEyePackObject.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface SkyEyePackObject : NSObject
@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,assign) int headIndex;
@property(nonatomic,copy) NSString *fileName;
@end

NS_ASSUME_NONNULL_END
