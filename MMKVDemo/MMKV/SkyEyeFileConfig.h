//
//  SkyEyeFileConfig.h
//  MMKVDemo
//
//  Created by 史贵岭 on 2020/7/13.
//  Copyright © 2020 Lingol. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PREFIXNAME(MFKV);
NS_ASSUME_NONNULL_BEGIN

//新的类型向后追加
typedef  NS_ENUM(NSInteger,SkyEyeConfigType) {
    SkyEyeConfigTypeInstallTime = 1,//应用安装时间
    SkyEyeConfigTypeProtocolVersion,//协议版本
    SkyEyeConfigTypeTMPSessionEndTime,//session临时结束时间，每2s定时写入
    SkyEyeConfigTypeSessionID,//session的ID
    SkyEyeConfigTypeSessionStartTime,//session开始时间
    SkyEyeConfigTypeSessionEndTime,//session结束时间
    SkyEyeConfigTypeIsInitialized,//是否初始化
    SkyEyeConfigTypeLatitude,//纬度
    SkyEyeConfigTypeLongitude,//经度
    SkyEyeConfigTypeIsOffline,//是否离线
    SkyEyeConfigTypeLastLaunchTime,//上次启动时间
    SkyEyeConfigTypeChannelBindEventSend,//channel绑定事件是否发送
    SkyEyeConfigTypeSavedIp,//保存IP地址
    SkyEyeConfigTypeSavedIp2,//保存IP地址2
    SkyEyeConfigTypeDataMigrateDone,//数据迁移是否完成
    SkyEyeConfigTypeTempPageView,//临时的PageView数据，比如调用trackPagebegin，没有调用end
    SkyEyeConfigTypeUserInfo,//存储用户账户信息
    SkyEyeConfigTypeUploadControl,//控制上报频率
    SkyEyeConfigTypeDeviceID,//设备ID
    
};
@interface SkyEyeFileConfig : NSObject

+(instancetype) sharedInstance;
-(void) setSkyEyeMMKV:(PREFIXNAME(MFKV) *) mkv;
-(void) trim;

- (nullable id)getObjectOfClass:(Class)cls forType:(SkyEyeConfigType) type;
- (int64_t)getInt64ForType:(SkyEyeConfigType) type;
- (BOOL) getBoolForType:(SkyEyeConfigType) type;
- (double) getDoubleForType:(SkyEyeConfigType) type;

//value为空代表移除类型为type的key
-(void) setConfig:(nullable NSObject<NSCoding> *)object forType:(SkyEyeConfigType) type;
-(void) setInt64:(int64_t)value forType:(SkyEyeConfigType) type;
-(void) setBool:(BOOL)value forType:(SkyEyeConfigType) type;
-(void) setDouble:(double) value forType:(SkyEyeConfigType) type;
@end

NS_ASSUME_NONNULL_END
