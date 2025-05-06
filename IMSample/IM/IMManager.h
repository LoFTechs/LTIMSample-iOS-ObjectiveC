//
//  IMManager.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <LTSDK/LTSDK.h>
#import <LTIMSDK/LTIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMManagerDelegate <NSObject>
@optional
- (void)onInit:(BOOL)success;
// Connect
- (void)onConnected;
- (void)onDisconnected;
// Profile
- (void)onQueryMyUserProfile:(LTUserProfile *)userProfile;
- (void)onQueryMyApnsSetting:(LTQueryUserDeviceNotifyResponse *)myApnsSetting;
- (void)onSetMyNickname:(NSDictionary *)userProfile;
- (void)onSetApnsMute:(BOOL)success;
- (void)onSetApnsDisplay:(BOOL)success;
- (void)onNeedQueryMyProfile;//MyProfileVC
// Create Channel
- (void)onCreateChannel:(NSString *)chID;
// Channel
- (void)onQueryChannels:(NSArray<LTChannelResponse *> *)channels;
- (void)onQueryChannel:(LTChannelResponse *)channel;
- (void)onChangeChannelPreference:(LTChannelPreference *)preference;
- (void)onChangeChannelProfile:(LTChannelProfileResponse *)profile;
- (void)onChannelChanged;//ChatSettingVC
// Message
- (void)onDidSendMessage;//ChatVC
- (void)onIncomingMessage:(LTMessageResponse *)message;//ChatVC
- (void)onQueryMessages:(NSArray<LTMessageResponse *> *)messages;
- (void)onNeedQueryMessage;//ChatVC
// Member
- (void)onQueryChannelMembers:(LTQueryChannelMembersResponse *)response;
- (void)onMemberChanged;//ChatSettingVC, MemberListVC
@end

@interface IMManager : NSObject

@property (nonatomic, strong) LTUser *currentUser;
@property (nonatomic, strong, nullable) LTChannelResponse *currentChannel;
@property (nonatomic, assign) BOOL initSuccess;
@property (nonatomic, assign) BOOL enableConnect;

+ (instancetype)sharedInstance;

- (void)addDelegate:(id<IMManagerDelegate>)delegate;
- (void)removeDelegate:(id<IMManagerDelegate>)delegate;
// Connect
- (void)initSDK;
- (void)connect;
- (void)disconnect;
// APNS
- (void)setupAPNS;
- (void)setPushToken:(NSString *)token;
- (void)clickAPNS:(LTPushNotificationMessage * _Nullable)message;
// Profile
- (void)queryMyUserProfile;
- (void)queryMyApnsSetting;
- (void)setMyNickname:(NSString *)nickname;
- (void)setApnsMute:(BOOL)mute;
- (void)setApnsDisplaySender:(BOOL)displaySender displayContent:(BOOL)displayContent;
// Create Channel
- (void)createSingleChannelWithMember:(LTMemberModel *)member;
- (void)createGroupChannelWithMembers:(NSArray *)members subject:(NSString *)subject;
// Channel
- (void)queryChannels;
- (void)queryChannelWithChID:(NSString *)chID;
- (void)setChannelSubject:(NSString *)subject;
- (void)setMyChannelNickname:(NSString *)nickname;
- (void)setChannelMute:(BOOL)mute;
- (void)dismissChannel;
- (void)leaveChannel;
// Message
- (void)queryMessages;
- (void)sendTextMessageWithText:(NSString *)text;
- (void)sendImageMessageWithThumbnailPath:(NSString *)thumbnailPath imagePath:(NSString *)imagePath;
- (void)sendDocumentMessageWithFilePath:(NSString *)filePath;
- (void)deleteLTMessageWithMsgID:(NSString *)msgID;
- (void)recallLTMessageWithMsgID:(NSString *)msgID;
// Member
- (void)queryChannelMemberWithLastUserID:(NSString *)lastUserID count:(NSUInteger)count;
- (void)kickUser:(NSString *)userID;
- (void)inviteWithMembers:(NSArray *)members;

@end

NS_ASSUME_NONNULL_END
