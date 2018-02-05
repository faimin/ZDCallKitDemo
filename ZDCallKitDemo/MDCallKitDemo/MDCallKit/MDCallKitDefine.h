//
//  MDCallKitDefine.h
//  MDCallKitDemo
//
//  Created by Zero.D.Saber on 2018/1/30.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#ifndef MDCallKitDefine_h
#define MDCallKitDefine_h

#if (DEBUG && 1)
#define CallLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define CallLog(...) ((void)0);
#endif

static NSString * const kVoipTokenKey = @"voip_token";
static NSString * const kCallsChangedNotificationName = @"kCallsChangedNotificationName";

#endif /* MDCallKitDefine_h */
