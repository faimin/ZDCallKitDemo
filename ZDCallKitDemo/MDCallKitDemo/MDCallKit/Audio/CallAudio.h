/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 High-level call audio management functions
 */

#import <Foundation/Foundation.h>
#import "AudioController.h"

@interface CallAudio : NSObject

+ (instancetype)sharedCallAudio;

- (void)configureAudioSession;
- (void)startAudio;
- (void)stopAudio;

@end
