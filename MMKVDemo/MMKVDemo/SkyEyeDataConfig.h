//
//  SkyEyeDataConfig.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/17.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkyEyeP.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * 桶的定义,每个桶存放N组，每组M个对象
 */
@interface SkyEyeDataConfig : NSObject<NSCoding>
@property(nonatomic,assign) int leftSize;//桶可用空间
@property(nonatomic,copy) NSString *fileName;//可以直接映射桶的文件名
@property(nonatomic,strong) NSMutableArray *sessionGroupArray;//桶包含哪几组数据
@property(nonatomic,strong) NSMutableArray *exceptionGroupArray;//桶包含哪几组数据
@property(nonatomic,strong) NSMutableArray *pageGroupArray;//桶包含哪几组数据
@property(nonatomic,strong) NSMutableArray *eventGroupArray;//桶包含哪几组数据
//为了减少存储空间以下标作为文件名
-(instancetype) initWithMaxSize:(int) maxSize fileName:(NSString *) fileName;
-(BOOL) containsIndex:(int) index type:(SkyEyeStoreDataType) type;

@end


NS_ASSUME_NONNULL_END
