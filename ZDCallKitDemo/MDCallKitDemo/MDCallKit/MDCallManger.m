//
//  MDCallManger.m
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "MDCallManger.h"
#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import "MDProviderDelegate.h"
#import "MDCallCategory.h"
#import "MDCall.h"
#import "MDCallKitDefine.h"

@interface MDCallManger () <PKPushRegistryDelegate>
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) MDProviderDelegate *providerDelegate;
@property (nonatomic, strong) NSMutableSet<MDCall *> *calls;
@end

@implementation MDCallManger

#pragma mark - ShareInstance

+ (instancetype)shareManager {
    static MDCallManger *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[super allocWithZone:NULL] init];
    });
    return manger;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareManager];
}

#pragma mark -

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self registerPushKit];
    [self monitorNotification];
}

- (void)registerPushKit {
    // nil表示默认主队列
    PKPushRegistry *pushRegister = [[PKPushRegistry alloc] initWithQueue:nil];
    pushRegister.delegate = self;
    pushRegister.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void)monitorNotification {
    
}

#pragma mark - Call Actions

- (void)starCallWithHandle:(NSString *)handleString video:(BOOL)isVideo {
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handleString];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID UUID] handle:handle];
    startCallAction.video = isVideo;
    
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    [self requestTransaction:transaction];
}

- (void)endCall:(MDCall *)call {
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:call.uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
    [self requestTransaction:transaction];
}

- (void)heldCall:(MDCall *)call onHold:(BOOL)onHold {
    CXSetHeldCallAction *heldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:call.uuid onHold:onHold];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:heldCallAction];
    [self requestTransaction:transaction];
}

#pragma mark - Storage

- (MDCall *)callWithUUID:(NSUUID *)uuid {
    if (!uuid) return nil;
    
    __block MDCall *call;
    [self.calls enumerateObjectsUsingBlock:^(MDCall * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.uuid.UUIDString isEqualToString:uuid.UUIDString]) {
            call = obj;
            *stop = YES;
        }
    }];
    return call;
}

- (void)addCall:(MDCall *)call {
    if (!call) return;
    
    [self.calls addObject:call];
    
    __weak typeof(self) weakTarget = self;
    call.stateDidChange = ^{
        __strong typeof(weakTarget) self = weakTarget;
        [self postCallsChangedNotification];
    };
    
    [self postCallsChangedNotification];
}

- (void)removeCall:(MDCall *)call {
    if (!call) return;
    
    [self.calls removeObject:call];
    [self postCallsChangedNotification];
}

- (void)removeAllCalls {
    [self.calls removeAllObjects];
    [self postCallsChangedNotification];
}

#pragma mark - Private Method

- (void)requestTransaction:(CXTransaction *)transaction {
    NSCAssert(transaction, @"what's wrong ????");
    if (!transaction) return;
    
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            CallLog(@"Error requesting transaction: %@", error.localizedDescription);
        } else {
            CallLog(@"Requested transaction successfully");
        }
    }];
}

- (void)postCallsChangedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallsChangedNotificationName object:self];
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVoipTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    NSString *token = [NSString stringWithFormat:@"%@", pushCredentials.token];
    NSString *tokenString = [[[token stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
#ifdef DEBUG
    //开发机账号特殊逻辑,携带"sandbox-"前缀的,就会走沙箱逻辑
    tokenString = [NSString stringWithFormat:@"sandbox-%@", tokenString];
#endif
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kVoipTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// VoIP push过来获取呼叫的信息
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion {
    [self handleReceiveIncomingPushWithPayload:payload forType:type];
}
#else
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    [self handleReceiveIncomingPushWithPayload:payload forType:type];
}
#endif

- (void)handleReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    if (type != PKPushTypeVoIP) return;
    
    NSDictionary *payloadDict = payload.dictionaryPayload;
    NSString *uuidString = payloadDict[@"UUID"];
    NSString *handle = payloadDict[@"handle"];
    BOOL hasVideo = [payloadDict[@"hasVideo"] boolValue];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    [self.providerDelegate reportIncomingCallWithUUID:uuid handle:handle hasVideo:hasVideo onCompletion:^(NSError *error) {
        CallLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - Property

- (MDProviderDelegate *)providerDelegate {
    if (!_providerDelegate) {
        _providerDelegate = [[MDProviderDelegate alloc] initWithCallManager:self];
    }
    return _providerDelegate;
}

- (CXCallController *)callController {
    if (!_callController) {
        _callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    }
    return _callController;
}

- (NSMutableSet<MDCall *> *)calls {
    if (!_calls) {
        _calls = [NSMutableSet set];
    }
    return _calls;
}

@end


@implementation MDCallModel
@end



