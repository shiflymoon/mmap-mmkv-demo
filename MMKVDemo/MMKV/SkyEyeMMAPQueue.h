//
//  SkyEyeMMAPQueue.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PREFIXNAME(MMAPQueue) : NSObject<NSCoding>
-(void) setMaxQueueNum:(int) maxQueue;
-(int) queueHead;
-(int) queueTail;
-(void) queueHeadMove;
-(void) queueTailMove;
-(BOOL) isQueueFull;
-(BOOL) isQueueEmpty;
@end

NS_ASSUME_NONNULL_END
