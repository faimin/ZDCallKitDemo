//
//  MDCallCategory.h
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

@interface CXTransaction (MDCall)

+ (CXTransaction *)transactionWithActions:(NSArray<CXAction *> *)actions;

@end


@interface NSURL (MDCall)

- (NSString *)startCallHandle;

@end

@interface NSUserActivity (MDCall)

@property(nonatomic, copy  ) NSString *startCallHandle;
@property(nonatomic, assign) BOOL video;

@end
