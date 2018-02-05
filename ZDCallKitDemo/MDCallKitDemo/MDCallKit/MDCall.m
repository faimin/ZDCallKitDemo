//
//  MDCall.m
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "MDCall.h"

@interface MDCall (){
@private
    BOOL _hasStartedConnecting;
    BOOL _hasConnected;
    BOOL _hasEnded;
}
@property (nonatomic, assign) BOOL hasStartedConnecting;    ///< 开始尝试建立通话连接
@property (nonatomic, assign) BOOL hasConnected;            ///< 成功建立通话连接
@property (nonatomic, assign) BOOL hasEnded;                ///< 通话结束

@property (nonatomic, assign) MDCallState callState;
@property (nonatomic, assign) MDConnectedState connectedState;
@end

@implementation MDCall

- (instancetype)initWithUUID:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing {
    if (self = [super init]) {
        _uuid = uuid;
        _isOutgoing = isOutgoing;
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

- (void)startCall:(void(^)(BOOL))completion {
    if (completion) {
        completion(YES);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hasStartedConnecting = YES;
        
        self.callState = MDCallState_Connecting;
        self.connectedState = MDConnectedState_Pending;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hasConnected = YES;
            
            self.callState = MDCallState_Active;
            self.connectedState = MDConnectedState_Complete;
        });
    });
}

- (void)answerCall {
    self.hasConnected = YES;
    
    self.callState = MDCallState_Active;
}

- (void)endCall {
    self.hasEnded = YES;
    
    self.callState = MDCallState_Ended;
}

- (NSTimeInterval)talkDuration {
    if (!self.connectDate) return 0;
    
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - [self.connectDate timeIntervalSince1970];
    return duration;
}

#pragma mark - Setter && Getter

- (void)setCallState:(MDCallState)callState {
    if (_callState != callState) {
        _callState = callState;
        
        !self.callStateChanged ?: self.callStateChanged(callState);
    }
}

- (void)setConnectedState:(MDConnectedState)connectedState {
    if (_connectedState != connectedState) {
        _connectedState = connectedState;
        
        !self.connectedStateChanged ?: self.connectedStateChanged(connectedState);
    }
}

//------------------------------------------------------------

- (void)setConnectingDate:(NSDate *)connectingDate {
    if (_connectingDate != connectingDate) {
        _connectingDate = connectingDate;
        
        if (self.stateDidChange) {
            self.stateDidChange();
        }
        if (self.hasStartedConnectingDidChange) {
            self.hasStartedConnectingDidChange();
        }
    }
}

- (void)setConnectDate:(NSDate *)connectDate {
    if (_connectDate != connectDate) {
        _connectDate = connectDate;
        
        if (self.stateDidChange) {
            self.stateDidChange();
        }
        if (self.hasConnectedDidChange) {
            self.hasConnectedDidChange();
        }
    }
}

- (void)setEndDate:(NSDate *)endDate {
    if (_endDate != endDate) {
        _endDate = endDate;
        
        if (self.stateDidChange) {
            self.stateDidChange();
        }
        if (self.hasEndedDidChange) {
            self.hasEndedDidChange();
        }
    }
}

- (void)setIsOnHold:(BOOL)isOnHold {
    if (_isOnHold != isOnHold) {
        _isOnHold = isOnHold;
        
        if (self.stateDidChange) {
            self.stateDidChange();
        }
    }
}

//------------------------------------------------------------

- (void)setHasStartedConnecting:(BOOL)hasStartedConnecting {
    _hasStartedConnecting = hasStartedConnecting;
    self.connectingDate = hasStartedConnecting ? [NSDate date] : nil;
}

- (BOOL)hasStartedConnecting {
    return (self.connectingDate != nil);
}

- (void)setHasConnected:(BOOL)hasConnected {
    _hasConnected = hasConnected;
    self.connectDate = hasConnected ? [NSDate date] : nil;
}

- (BOOL)hasConnected {
    return self.connectDate != nil;
}

- (void)setHasEnded:(BOOL)hasEnded {
    _hasEnded = hasEnded;
    self.endDate = hasEnded ? [NSDate date] : nil;
}

- (BOOL)hasEnded {
    return (self.endDate != nil);
}

@end
