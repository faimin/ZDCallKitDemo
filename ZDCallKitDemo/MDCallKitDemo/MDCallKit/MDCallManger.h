//
//  MDCallManger.h
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//
//  plist中的Required Background Modes添加App provides Voice over IP service设置(Voip)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MDCall;
@interface MDCallManger : NSObject

@property (nonatomic, strong, readonly) NSMutableSet<MDCall *> *calls;

+ (instancetype)shareManager;

- (void)starCallWithHandle:(NSString *)handleString video:(BOOL)isVideo;
- (void)endCall:(MDCall *)call;
- (void)heldCall:(MDCall *)call onHold:(BOOL)onHold;

- (MDCall *)callWithUUID:(NSUUID *)uuid;
- (void)addCall:(MDCall *)call;
- (void)removeCall:(MDCall *)call;
- (void)removeAllCalls;

@end


@interface MDCallModel : NSObject
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, copy  ) NSString *displayName;
@property (nonatomic, copy  ) NSString *phoneNumber;
@end

NS_ASSUME_NONNULL_END
