//
//  MDProviderDelegate.m
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "MDProviderDelegate.h"
#import <UIKit/UIKit.h>
#import "MDCallManger.h"
#import "MDCall.h"

@interface MDProviderDelegate () 
@property (nonatomic, weak) MDCallManger *callManager;
@property (nonatomic, strong) CXProvider *provider;
@end

@implementation MDProviderDelegate

- (instancetype)initWithCallManager:(MDCallManger *)callManger {
    if (self = [super init]) {
        _callManager = callManger;
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

- (void)reportIncomingCallWithUUID:(NSUUID *)uuid handle:(NSString *)handleString hasVideo:(BOOL)hasVideo onCompletion:(void(^)(NSError *))completion {
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    callUpdate.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handleString];
    callUpdate.hasVideo = hasVideo;
    
    [self.provider reportNewIncomingCallWithUUID:uuid update:callUpdate completion:^(NSError * _Nullable error) {
        if (!error) {
            MDCall *call = [[MDCall alloc] initWithUUID:uuid isOutgoing:NO];
            call.handle = handleString;
            [self.callManager addCall:call];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - CXProviderDelegate

- (void)providerDidReset:(CXProvider *)provider {
    //stopAudio();
    for (MDCall *call in self.callManager.calls) {
        [call endCall];
    }
    [self.callManager removeAllCalls];
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    MDCall *callHandler = [[MDCall alloc] initWithUUID:action.UUID isOutgoing:YES];
    callHandler.handle = action.handle.value;
    // configuration audiosession
    __weak typeof(self) weakTarget = self;
    __weak typeof(callHandler) weakCallHandler = callHandler;
    callHandler.hasStartedConnectingDidChange = ^{
        __strong typeof(weakTarget) self = weakTarget;
        __strong typeof(weakCallHandler) callHandler = weakCallHandler;
        [self.provider reportOutgoingCallWithUUID:callHandler.uuid startedConnectingAtDate:callHandler.connectingDate];
    };
    callHandler.hasConnectedDidChange = ^{
        __strong typeof(weakTarget) self = weakTarget;
        __strong typeof(weakCallHandler) callHandler = weakCallHandler;
        [self.provider reportOutgoingCallWithUUID:callHandler.uuid connectedAtDate:callHandler.connectDate];
    };
    
    [callHandler startCall:^(BOOL isSuccess) {
        if (isSuccess) {
            [action fulfill];
            [self.callManager addCall:callHandler];
        }
        else {
            [action fail];
        }
    }];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    MDCall *call = [self.callManager callWithUUID:action.UUID];
    if (!call) {
        [action fail];
        return;
    }
    //configureAudioSession();
    
    [call answerCall];
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    MDCall *call = [self.callManager callWithUUID:action.UUID];
    if (!call) {
        [action fail];
        return;
    }
    call.isOnHold = action.isOnHold;
    
    if (call.isOnHold) {
        //stopAudio();
    } else {
        //startAudio();
    }
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    MDCall *call = [self.callManager callWithUUID:action.UUID];
    if (!call) {
        [action fail];
        return;
    }
    //stopAudio();
    
    [call endCall];
    
    [action fulfill];
    
    [self.callManager removeCall:call];
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    //startAudio();
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    
}

#pragma mark -

- (CXProvider *)provider {
    if (!_provider) {
        //本地显示的应用名字
        CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"要呼叫的人名"];
        configuration.supportsVideo = YES;
        configuration.maximumCallsPerCallGroup = 1;
        configuration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
        configuration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"logo.png"]);
        configuration.ringtoneSound = @"Ringtone.aif";//如果没有音频文件 就用系统的
        
        CXProvider *provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [provider setDelegate:self queue:dispatch_get_main_queue()];
        _provider = provider;
    }
    return _provider;
}

@end
