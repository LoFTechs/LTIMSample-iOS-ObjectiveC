//
//  Utility.m
//  LTIMSample
//
//  Created by shane on 2025/4/18.
//  Copyright © 2025 LoFTech. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (NSString *)getContentWithMsgType:(LTMessageType)msgType msgContent:(NSString *)msgContent {
    if (msgType == LTMessageTypeAnswerInvition) {
        return @"Join channel.";
    } else if (msgType == LTMessageTypeCreateChannel) {
        return @"Create a channel.";
    } else if (msgType == LTMessageTypeInviteChatroom) {
        return @"Invite members.";
    } else if (msgType == LTMessageTypeLeaveChannel) {
        return @"Leave channel.";
    } else if (msgType == LTMessageTypeKickChannel) {
        return @"Kick members.";
    } else if (msgType == LTMessageTypeSetRoleID) {
        return @"Set members role.";
    } else if (msgType == LTMessageTypeSetChannelProfile) {
        return @"Set channel profile.";
    } else if (msgType == LTMessageTypeRecall) {
        return @"Recall messages";
    }
    
    return msgContent;
}

@end
