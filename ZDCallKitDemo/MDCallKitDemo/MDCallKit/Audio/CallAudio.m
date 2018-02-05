/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 High-level call audio management functions
 */

#import "CallAudio.h"

@interface CallAudio ()
@property (nonatomic, strong) AudioController * audioController;
@end

@implementation CallAudio

+ (instancetype)sharedCallAudio {
    static CallAudio *_audio = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audio = [[super allocWithZone:NULL] init];
    });
    return _audio;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedCallAudio];
}

- (void)configureAudioSession {
    NSLog(@"Configuring audio session");
    if (_audioController == nil) {
        _audioController = [[AudioController alloc] init];
    }
}

- (void)startAudio {
    NSLog(@"Starting audio");
    
    if ([_audioController startIOUnit] == kAudioServicesNoError) {
        [_audioController setMuteAudio:NO];
    } else {
        // handle error
    }
}

- (void)stopAudio {
    NSLog(@"Stopping audio");
    
    if ([_audioController stopIOUnit] == kAudioServicesNoError) {
        // handle error
    }
}


@end
