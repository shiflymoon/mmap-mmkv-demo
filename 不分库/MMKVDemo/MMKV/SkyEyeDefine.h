//
//  SkyEyeDefine.h
//  MMKV
//
//  Created by 史贵岭 on 2019/12/22.
//  Copyright © 2019 Lingol. All rights reserved.
//

#ifndef SkyEyeDefine_h
#define SkyEyeDefine_h
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PREFIXNAME(MMKVOnErrorDiscard) = 0,
    PREFIXNAME(MMKVOnErrorRecover),
} PREFIXNAME(MMKVRecoverStrategic);


typedef enum : NSUInteger {
    PREFIXNAME(MMKVLogDebug) = 0, // not available for release/product build
    PREFIXNAME(MMKVLogInfo) = 1,  // default level
    PREFIXNAME(MMKVLogWarning),
    PREFIXNAME(MMKVLogError),
    PREFIXNAME(MMKVLogNone), // special level used to disable all log messages
} PREFIXNAME(MMKVLogLevel);

// callback is called on the operating thread of the MMKV instance
@protocol PREFIXNAME(MMKVHandler) <NSObject>
@optional

// by default MMKV will discard all datas on crc32-check failure
// return `MMKVOnErrorRecover` to recover any data on the file
- (PREFIXNAME(MMKVRecoverStrategic))onMMKVCRCCheckFail:(NSString *)mmapID;

// by default MMKV will discard all datas on file length mismatch
// return `MMKVOnErrorRecover` to recover any data on the file
- (PREFIXNAME(MMKVRecoverStrategic))onMMKVFileLengthError:(NSString *)mmapID;

// by default MMKV will print log using NSLog
// implement this method to redirect MMKV's log
- (void)mmkvLogWithLevel:(PREFIXNAME(MMKVLogLevel))level file:(const char *)file line:(int)line func:(const char *)funcname message:(NSString *)message;

@end
#endif /* SkyEyeDefine_h */
