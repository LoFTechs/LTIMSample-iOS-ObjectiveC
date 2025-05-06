//
//  Utility.h
//  LTIMSample
//
//  Created by shane on 2025/4/18.
//  Copyright © 2025 LoFTech. All rights reserved.
//

#import <LTIMSDK/LTIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utility : NSObject

+ (NSString *)getContentWithMsgType:(LTMessageType)msgType msgContent:(NSString *)msgContent;

@end

NS_ASSUME_NONNULL_END
