//
//  MDCall.h
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MDCallState) {
    MDCallState_Ended,          ///< 通话结束或者没有通话状态
    MDCallState_Connecting,     ///< 尝试建立连接中(正在呼叫)
    MDCallState_Active,         ///< 通话中(已成功建立连接)
    MDCallState_Held,           ///< 呼叫等待(被其他电话打断处于挂起状态)
};

typedef NS_ENUM(NSInteger, MDConnectedState) {
    MDConnectedState_Pending,   ///< 等待建立连接ing
    MDConnectedState_Complete,  ///< 连接成功
};

@interface MDCall : NSObject

// Property
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, assign) BOOL isOutgoing;
@property (nonatomic, copy  ) NSString *handle;

@property (nonatomic, strong) NSDate *connectingDate;
@property (nonatomic, strong) NSDate *connectDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) BOOL isOnHold;

@property (nonatomic, copy  ) dispatch_block_t stateDidChange;
@property (nonatomic, copy  ) dispatch_block_t hasStartedConnectingDidChange;
@property (nonatomic, copy  ) dispatch_block_t hasConnectedDidChange;
@property (nonatomic, copy  ) dispatch_block_t hasEndedDidChange;

@property (nonatomic, copy  ) void(^callStateChanged)(MDCallState);
@property (nonatomic, copy  ) void(^connectedStateChanged)(MDConnectedState);

// Methods
- (instancetype)initWithUUID:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing;
- (void)startCall:(void(^)(BOOL))completion;
- (void)answerCall;
- (void)endCall;
- (NSTimeInterval)talkDuration;

@end
