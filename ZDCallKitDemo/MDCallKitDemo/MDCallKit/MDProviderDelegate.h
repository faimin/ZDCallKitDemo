//
//  MDProviderDelegate.h
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//
//  被MDCallManager单例持有，所以不会释放

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

@class MDCallManger;
@interface MDProviderDelegate : NSObject <CXProviderDelegate>

- (instancetype)initWithCallManager:(MDCallManger *)callManger;

- (void)reportIncomingCallWithUUID:(NSUUID *)uuid
                            handle:(NSString *)handleString
                          hasVideo:(BOOL)hasVideo
                      onCompletion:(void(^)(NSError *))completion;

@end
