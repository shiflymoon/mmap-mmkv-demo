//
//  SkyEyeDataManager.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "SkyEyeDataManager.h"
#import "SkyEyeMMAPQueue.h"
#import "SkyEyeDataConfig.h"
#import <unistd.h>
#import <CommonCrypto/CommonDigest.h>

static int SkyEyeMaxItemCount = 30;
static int SkyEyePageSizeCount = 120;
@interface SkyEyeDataManager ()
{
    SkyEyeMFKV * _mkv;
    SkyEyeMFKV * _currentMKV;
    SkyEyeDataConfig * _currentDataConfig;
    SkyEyeMMAPQueue * _queue;
    int _mmapFileSize;
}
@end
@implementation SkyEyeDataManager

+(instancetype) sharedInstance {
    static SkyEyeDataManager * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(instancetype) init {
    self = [super init];
    if(self) {
        _mmapFileSize = getpagesize() * SkyEyePageSizeCount  ;//16k*120 约为2M
    }
    return self;
}

-(void) setSkyEyeMMKV:(SkyEyeMFKV *) mkv
{
    _mkv = mkv; 
    [self loadQueue];
}

-(void) addData:(id) data {
    if(!data) {
        return;
    }
    
    /* //需要验证这个函数的效率
     NSData *data;
     if ([PREFIXNAME(MiniPBCoder) isMiniPBCoderCompatibleObject:object]) {
     data = [PREFIXNAME(MiniPBCoder) encodeDataWithObject:object];
     } else {
     {
     data = [NSKeyedArchiver archivedDataWithRootObject:object];
     }
     }*/
    @autoreleasepool {//频繁操作的函数，需要增加自动释放池子，构造的临时对象太多，内存会爆掉
                
        NSData *binaryData = nil;
        if([data isKindOfClass:[NSData class]]){
            binaryData = data;
        }else {
            @try {
                 binaryData =  [NSKeyedArchiver archivedDataWithRootObject:data]; 
            } @catch (NSException *exception) {
                return;
            } 
        }
        
        if(binaryData.length >= _mmapFileSize) {//超出单个文件上限
            return;
        }
        
        int tail = [_queue queueTail];
        NSString * tailKey  = [NSString stringWithFormat:@"%d",tail];
        
        //获取目前已有的桶，每个桶有若干组数据
        NSArray * dataFileConfigArray = [_mkv getObjectOfClass:[NSArray class] forKey:@"dataConfig"];
        
        // 判断是否满了
        if([_queue isQueueFull]) {//如果真满，tail一定存在某一个桶中，遍历桶中config，看元素是否满了
            for(SkyEyeDataConfig * td in dataFileConfigArray){
                for(NSNumber * indexObj in td.groupArray){
                    if(indexObj.intValue == tail ){
                        SkyEyeMFKV *tailMKV = [SkyEyeMFKV mmkvWithID:td.fileName];
                        NSArray *tData = [tailMKV getObjectOfClass:[NSArray class] forKey:tailKey];
                        if(tData.count >= SkyEyeMaxItemCount){
                            [tailMKV close];
                            return;
                        }
                        
                    }
                }
            }
        }
        __block BOOL contains = [_currentDataConfig containsIndex:tail];
        if(dataFileConfigArray.count == 0) {
            SkyEyeDataConfig *config = [self makeNewDataConfigWithIndex:tail];
            [_mkv setObject:@[config] forKey:@"dataConfig"];
        }else if(!contains) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{//首次从本地加在数据到内存
                
                //如果存在找到tail所在的桶，否则找到一个能存下新增加数据的桶
                SkyEyeDataConfig *tempConfig = nil;
                for(SkyEyeDataConfig *t in dataFileConfigArray){
                    if([t containsIndex:tail]){
                        tempConfig = t;
                        contains = YES;
                        break;
                    }
                    if(!tempConfig && t.leftSize >= binaryData.length){
                        tempConfig = t;
                    }
                }
                
                if(!tempConfig) {//找不到，且当前的所有桶空间不足
                    [self makeNewDataConfigWithIndex:tail];
                }else {
                    _currentDataConfig = tempConfig;
                    _currentMKV = [SkyEyeMFKV mmkvWithID:_currentDataConfig.fileName];
                }
            });
            
        }
        
        NSArray * tData = nil;
        BOOL isConfigNew = NO;
        SkyEyeDataConfig *oldConfig = nil;
        //包含，不包含  ==》空间足，空间不足，四种组合
        if(contains && (_currentDataConfig.leftSize < binaryData.length || _currentMKV.actualSize > _mmapFileSize - binaryData.length)){//包含空间不足
            
            tData = [_currentMKV getObjectOfClass:[NSArray class] forKey:tailKey];
            
            NSData *rawData = [_currentMKV getRawDataForKey:tailKey];
            BOOL isGroupFull = NO;
            if(tData.count >= SkyEyeMaxItemCount) {//tail下标存储满了，需要存储在tail+1
                [_queue queueTailMove];
                [self saveQueue];
                isGroupFull = YES;
            }
            
            if(!isGroupFull) {//分组group没有满的话，需要移动到新的桶
                
                NSArray *tGroupArray = _currentDataConfig.groupArray;
                NSMutableArray * groupArray = [NSMutableArray arrayWithArray:tGroupArray];
                for(NSNumber * nu in tGroupArray) {
                    if(nu.intValue == tail) {
                        [groupArray removeObject:nu];
                    }
                }
                _currentDataConfig.leftSize += (int)rawData.length;
                _currentDataConfig.groupArray = groupArray;
                [_currentMKV removeValueForKey:tailKey];
            }
            oldConfig = _currentDataConfig;
            //关闭，减少内存占用
            [_currentMKV close];
            
            //为了保证写入顺序，只要空间不够，就新建桶
            [self makeNewDataConfigWithIndex:tail];
            
            NSMutableArray *newGroupArray = [NSMutableArray array];
            
            //新桶增加了新的下标
            [newGroupArray addObject:@([_queue queueTail])];
            
            //不能直接减去binaryData，因为以数组存储，数据会压缩
            _currentDataConfig.groupArray = newGroupArray;
            isConfigNew = YES;
            
        }else if(contains &&( _currentDataConfig.leftSize >= binaryData.length && _currentMKV.actualSize < _mmapFileSize - binaryData.length)) {//包含空间足
            tData = [_currentMKV getObjectOfClass:[NSArray class] forKey:tailKey];
            NSData *rawData = [_currentMKV getRawDataForKey:tailKey];
            
            NSMutableArray * groupArray = _currentDataConfig.groupArray;
            
            if(tData.count >= SkyEyeMaxItemCount) {//tail下标存储满了，需要存储在tail+1
                [_queue queueTailMove];
                [self saveQueue];
                [groupArray addObject:@([_queue queueTail])];
            }else {
                _currentDataConfig.leftSize += (int)rawData.length;//不知道刚添加的数据加到数组中被压缩数据大小，所以先加，最后再减 
            }
            
            //不能直接减去binaryData，因为以数组存储，数据会压缩
            _currentDataConfig.groupArray = groupArray;
            
            isConfigNew = NO;
            
        }else if(!contains && (_currentDataConfig.leftSize < binaryData.length || _currentMKV.actualSize > _mmapFileSize - binaryData.length)) {//不包含空间不足
            //关闭节约内存
            [_currentMKV close];
            //先遍历所有桶，只是当前桶找不到看下标tail是否存在其他的桶
            
            
            //为了保证写入顺序，只要空间不够，就新建桶
            [self makeNewDataConfigWithIndex:tail];
            NSMutableArray * groupArray = [NSMutableArray array];
            //新桶增加了新的下标
            [groupArray addObject:@(tail)];  
            
            
            //不能直接减去binaryData，因为以数组存储，数据会压缩
            _currentDataConfig.groupArray = groupArray;
            isConfigNew = YES;
            
        }else if(!contains && (_currentDataConfig.leftSize >= binaryData.length && _currentMKV.actualSize < _mmapFileSize - binaryData.length)) {//不包含空间足
            
            NSMutableArray * groupArray = [NSMutableArray array];
            [groupArray addObjectsFromArray:_currentDataConfig.groupArray];
            
            //新桶增加了新的下标
            [groupArray addObject:@(tail)];  
            
            
            //不能直接减去binaryData，因为以数组存储，数据会压缩
            _currentDataConfig.groupArray = groupArray;
            isConfigNew = NO;
        }
        
        NSMutableArray * editArray = [NSMutableArray array];
        
        if([tData count] >= SkyEyeMaxItemCount ) {//移动组，
            [editArray addObject:data];
            //        [_queue queueTailMove];
            //        [self saveQueue];
            tailKey  = [NSString stringWithFormat:@"%d",[_queue queueTail]];
        }else {
            [editArray addObjectsFromArray:tData];
            [editArray addObject:data];
        }
        [_currentMKV setObject:editArray forKey:tailKey];
        
        NSData *tRawData = [_currentMKV getRawDataForKey:tailKey];
        //这儿减去tailkey所有的大小，上面已经加上该加的大小，实际只减少了当前元素的大小
        _currentDataConfig.leftSize -= (int)tRawData.length;
        //更新桶数据　
        [self updateDataConfig:_currentDataConfig old:oldConfig isNew:isConfigNew];
    }
}

-(SkyEyePackObject *) getData {
    @autoreleasepool {
        
        int head = [_queue queueHead];
        NSString * headKey  = [NSString stringWithFormat:@"%d",head];
        
        //获取目前已有的桶，每个桶有若干组数据
        NSArray * dataFileConfigArray = [_mkv getObjectOfClass:[NSArray class] forKey:@"dataConfig"];
        SkyEyeDataConfig * _getDataConfig = nil;
        
        // 判断是否真空了
        if([dataFileConfigArray count] <= 0) {//没有任何桶
            return nil;
        } else if([_queue isQueueEmpty]) {   
            /*首尾指针相遇，可能存在数据，指针指向的数组容量存储了部分，比如数组容量30，只add了一个元素，默认head=tail=0
             *数据大小如果不能被容量整除，比如100，数组容量30，会有10个元素存在tail=3位置，这10个元素要取出来
             */
            BOOL empty = YES;
            for(SkyEyeDataConfig * td in dataFileConfigArray){
                if(td.groupArray.count >= 1){
                    empty = NO;
                    break;
                }
            }
            if(empty) {
                return nil;   
            }
            
        }
        
        //找到head所在的桶
        BOOL find = NO;
        for(SkyEyeDataConfig * td in dataFileConfigArray){
            for(NSNumber * indexObj in td.groupArray){
                if(indexObj.intValue == head ){
                    _getDataConfig = td;
                    find = YES;
                    break;
                }
            }
        }
        
        if(!find) {
            SkyEyeDataConfig *tmpDataConfig = nil;
            for(int i = 0; i<dataFileConfigArray.count; i++) {
                tmpDataConfig = dataFileConfigArray[i];
                if(tmpDataConfig.groupArray.count >=1 ){
                    break;
                }else {
                    tmpDataConfig = nil;
                }
            }
            if(!tmpDataConfig) {
                return nil;
            }
            _getDataConfig = tmpDataConfig;
            head = ((NSNumber *)[_getDataConfig.groupArray firstObject]).intValue;
        }
        
        SkyEyeMFKV * _getDataMKV =  [SkyEyeMFKV mmkvWithID:_getDataConfig.fileName];
        NSArray * tData = [_getDataMKV getObjectOfClass:[NSArray class] forKey:headKey];
        SkyEyePackObject * packObj = [[SkyEyePackObject alloc] init];
        packObj.fileName = _getDataConfig.fileName;
        [packObj.dataArray addObjectsFromArray:tData];
        
        packObj.headIndex = head;
        [_getDataMKV close];
        
        return packObj;
    }
}

-(void) removeData:(SkyEyePackObject *)pObject
{
    @autoreleasepool {
        
        if(!pObject) {
            return;
        }
        //获取目前已有的桶，每个桶有若干组数据
        NSArray * dataFileConfigArray = [_mkv getObjectOfClass:[NSArray class] forKey:@"dataConfig"];
        SkyEyeDataConfig *rConfig = nil;
        for(SkyEyeDataConfig *config in dataFileConfigArray) {
            if([config.fileName isEqualToString: pObject.fileName]){
                rConfig = config;
                break;
            }
        }
        
        SkyEyeMFKV * _getDataMKV =  [SkyEyeMFKV mmkvWithID:pObject.fileName];
        NSString * removeKey  = [NSString stringWithFormat:@"%d",pObject.headIndex];
        if(rConfig) {
            NSNumber *findIndexDesc = nil;
            for(NSNumber *indexDesc in rConfig.groupArray) {
                if(indexDesc.intValue == pObject.headIndex){
                    findIndexDesc = indexDesc;
                    break;
                }
            }
            NSMutableArray *groupArray = rConfig.groupArray;
            if(findIndexDesc) {
                [groupArray removeObject:findIndexDesc];
            }
            rConfig.groupArray = groupArray;
            rConfig.leftSize +=(int) [_getDataMKV getRawDataForKey:removeKey].length;
            
            [self updateDataConfig:rConfig old:nil isNew:NO];
        }
        
        
        [_getDataMKV removeValueForKey:removeKey];
        [_getDataMKV close];
        
        [_queue queueHeadMove];
        [self saveQueue];
        
    }
}

#pragma mark - private

-(NSString *)md5String:(NSString *)input {
    NSMutableString *hashedUUID = nil;
    @try {
        NSData *stringBytes = [input dataUsingEncoding: NSUTF8StringEncoding];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        
        if (CC_MD5([stringBytes bytes], (CC_LONG)[stringBytes length], digest)) {
            hashedUUID = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
            for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
                [hashedUUID appendFormat:@"%02x", digest[i]];
            }
        }
    }
    @catch (...) {
    }
    
    return hashedUUID;
}

-(void) loadQueue {
    _queue = [_mkv getObjectOfClass:[SkyEyeMMAPQueue class] forKey:@"Queue"];
    if(!_queue){
        _queue = [[SkyEyeMMAPQueue alloc] init];
    }
}

-(SkyEyeDataConfig *) makeNewDataConfigWithIndex:(int) index {
    NSString *fileName = [self md5String:[[NSUUID UUID] UUIDString]];
    SkyEyeDataConfig *config = [[SkyEyeDataConfig alloc] initWithMaxSize:_mmapFileSize fileName:fileName];
    /*
    SkyEyeIndexDesc *indexDesc = [[SkyEyeIndexDesc alloc] initWithItemCount:0 index:index];
    config.groupArray = [@[indexDesc] mutableCopy];*/
    _currentMKV = [SkyEyeMFKV mmkvWithID:fileName];
    _currentDataConfig = config;
    return config;
}

-(void) updateDataConfig:(SkyEyeDataConfig *) newConfigData old:(SkyEyeDataConfig *) oldConfigData isNew:(BOOL) isNew {
    //更新桶数据　
    NSArray * allDataConfig = [_mkv getObjectOfClass:[NSArray class] forKey:@"dataConfig"];
    NSMutableArray * tAllDataConfig = [NSMutableArray array];
    if(allDataConfig.count) {
        [tAllDataConfig addObjectsFromArray:allDataConfig];
    }
    
    for(int i =0 ; i<allDataConfig.count ;i++) {
        SkyEyeDataConfig *t = allDataConfig[i];
        if([t.fileName isEqualToString:oldConfigData.fileName]) {
            [tAllDataConfig replaceObjectAtIndex:i withObject:oldConfigData];
        }
        if([t.fileName isEqualToString:newConfigData.fileName ]) {
            [tAllDataConfig replaceObjectAtIndex:i withObject:newConfigData];
        }
    }
    if(isNew) {
        [tAllDataConfig addObject:newConfigData];
    }
    
    [_mkv setObject:tAllDataConfig forKey:@"dataConfig"];
}


-(void) saveQueue {
    if(!_queue){
        return;
    }   
    
    [_mkv setObject:_queue forKey:@"Queue"];
}
@end
