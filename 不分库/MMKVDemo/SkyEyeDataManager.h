//
//  SkyEyeDataManager.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkyEyePackObject.h"
#import <MMKV/SkyEyeMFKV.h>

/*
 * 基于key-value设计存储系统
 * 由于要存储几万个对象，而MMAP默认会全部加在到内存中，会占据内存几百M甚至会上G，
 * 为了控制对象总数，采用了循环队列方案，最大空间为M，用下标记录队列是否满，队列每个下标不是对应
 * 一个元素，而是一个包含N组数据的数组，最大可存储对象为M*N个
 *  如果M偏大，就不能把0,1,2,....M-1 这些key所对应对象放到一个MMAP文件（每个key都有N个元素）
 *  所以需要把这些key以及所管理的对象拆分到不同MMAP文件，每个文件MMAP文件设定一个上限比如2M，超过上限后
 *  分配一个新的MMAP文件，所以0,1,2...10这几个key会被分配到file1，11,12...15可能分配到file2
 *  另外由于限制了单个MMAP文件大小（最好为PageSize的整数倍）甚至会出现某个keyn增加一个元素后，对应的文件的空间不足
 *  此时需要将此keyn对应的文件的数据取出，放入新的文件，更新key对应的新文件，同时将key从旧文件中移除
 *  此处简单实现，一旦一个桶放不下了，直接开新桶，导致可能出现的问题是，有些桶内的下标没有存满，比如只存储了1个元素，上报
 *。 按照也可能只上报一条数据。
 */

NS_ASSUME_NONNULL_BEGIN

@interface SkyEyeDataManager : NSObject
-(void) setSkyEyeMMKV:(SkyEyeMFKV *) mkv;
+(instancetype) sharedInstance;


-(void) addData:(id) data;
-(SkyEyePackObject *) getData;
-(void) removeData:(SkyEyePackObject *) pObject;

//-(NSString *) get

@end

NS_ASSUME_NONNULL_END
