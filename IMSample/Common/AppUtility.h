//
//  AppUtility.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/15.
//

#import <LTIMSDK/LTIMSDK.h>

#import "Utility.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppUtility : NSObject

+ (void)alertWithString:(NSString *)string consoleString:(NSString *)consoleString;

+ (void)backToChatList;

@end

NS_ASSUME_NONNULL_END
