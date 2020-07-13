//
//  SkyEyeMMAPQueue.m
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/6/12.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import "SkyEyeMMAPQueue.h"

static int SkyeyeMMAPQueueMaxItem = 100000; /*1000 ;*/
static NSString * QueueHead = @"queuhead";
static NSString * QueueTail = @"queuetail";
@interface SkyEyeMMAPQueue()
{
    int _queueHead;
    int _queueTail;
    int _queueMax;
}
@end
@implementation SkyEyeMMAPQueue

-(instancetype) init {
    self = [super init];
    if(self) {
        _queueTail = 0;
        _queueHead = 0;
        _queueMax = SkyeyeMMAPQueueMaxItem;
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)coder {
    self = [super init];
    if(self) {
        _queueHead = [coder decodeIntForKey:QueueHead];
        _queueTail = [coder decodeIntForKey:QueueTail];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:_queueHead forKey:QueueHead];
    [coder encodeInt:_queueTail forKey:QueueTail];
}

-(void) setMaxQueueNum:(int)maxQueue {
    if(maxQueue >= 1) {
        _queueMax = maxQueue;
    }
}

-(int) queueHead {
    return _queueHead;
}

-(int) queueTail {
    return _queueTail;
}

-(void) queueHeadMove {
   _queueHead = ++_queueHead % _queueMax;
    if(_queueHead > _queueTail) {
        _queueHead = _queueTail;
    }
}

-(void) queueTailMove {
    _queueTail  = ++_queueTail % _queueMax;
}

-(BOOL) isQueueFull {
    return (_queueTail +1 ) % _queueMax == _queueHead;
}

-(BOOL) isQueueEmpty {
    return _queueHead == _queueTail ;
}
@end
