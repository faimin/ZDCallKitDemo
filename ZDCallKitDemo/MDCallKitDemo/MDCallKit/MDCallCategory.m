//
//  MDCallCategory.m
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/29.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "MDCallCategory.h"
#import <objc/runtime.h>
#import <Intents/Intents.h>

@implementation CXTransaction (MDCall)

+ (CXTransaction *)transactionWithActions:(NSArray<CXAction *> *)actions {
    CXTransaction *transcation = [[CXTransaction alloc] init];
    for (CXAction *action in actions) {
        [transcation addAction:action];
    }
    return transcation;
}

@end

@implementation NSURL (MDCall)
static NSString * const URLScheme = @"MDCallKit";

- (NSString *)startCallHandle {
    NSString *callHandle = URLScheme;
    if (!callHandle) {
        callHandle = self.host;
    }
    return callHandle;
}

@end

@implementation NSUserActivity (MDCall)

static const void *startCallHandleKey = &startCallHandleKey;
static const void *videoKey = &videoKey;

- (void)setVideo:(BOOL)video {
    objc_setAssociatedObject(self, videoKey, [NSNumber numberWithBool:video], OBJC_ASSOCIATION_COPY);
}

- (BOOL)video {
    INInteraction *interaction=self.interaction;
    INIntent *startCallIntent = interaction.intent;
    if (interaction && startCallIntent) {
        return [startCallIntent isKindOfClass:[INStartVideoCallIntent class]];
    } else {
        return nil;
    }
    return [objc_getAssociatedObject(self, videoKey) boolValue];
}

- (void)setStartCallHandle:(NSString *)startCallHandle {
    objc_setAssociatedObject(self, startCallHandleKey, startCallHandle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)startCallHandle {
    INInteraction *interaction = self.interaction;
    if (!interaction)  return nil;
    
    INIntent *startCallIntent = interaction.intent;
    if (!startCallIntent) return nil;
    
    INPerson *contact = nil;
    if ([startCallIntent isKindOfClass:[INStartAudioCallIntent class]]) {
        contact = ((INStartAudioCallIntent*)startCallIntent).contacts.firstObject;
    } else if ([startCallIntent isKindOfClass:[INStartVideoCallIntent class]]) {
        contact = ((INStartVideoCallIntent*)startCallIntent).contacts.firstObject;
    } else if ([startCallIntent isKindOfClass:[INSendMessageIntent class]]) {
        contact = ((INSendMessageIntent*)startCallIntent).recipients.firstObject;
    }
    
    if (contact) {
        return contact.personHandle.value;
    } else {
        return nil;
    }
    
    return objc_getAssociatedObject(self, startCallHandleKey);
}

@end
