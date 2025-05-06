//
//  ChatVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import "ChatVC.h"
#import "MessageCell.h"
#import "IMManager.h"

@interface ChatVC()<UITableViewDelegate, UITableViewDataSource, IMManagerDelegate, MessageCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *messageTVC;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _messageArray = [[NSMutableArray alloc] init];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IMManager sharedInstance] addDelegate:self];
    
    [self.activityView startAnimating];
    self.messageTVC.hidden = YES;
    [[IMManager sharedInstance] queryMessages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IMManager sharedInstance] removeDelegate:self];
}

- (void)initViews {
    [self.messageTVC registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
}


- (IBAction)sendMessage:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Send Message" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Input message...";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *message = alert.textFields.count > 0 ? [alert.textFields firstObject] : nil;
        if (message && message.text.length > 0) {
            [[IMManager sharedInstance] sendTextMessageWithText:message.text];
        }
    }];
    
    [alert addAction:actionOk];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:actionNo];
    
    [self presentViewController:alert animated:NO completion:nil];
}


//MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.delegate = self;
    
    LTMessageResponse *message = self.messageArray[indexPath.row];
    cell.lblSender.text = message.senderNickname ?: message.senderID;
    
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[NSLocale currentLocale].localeIdentifier];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.sendTime/1000];
    cell.lblSendTime.text = [dateFormatter stringFromDate:date];
    cell.btnDelete.tag = indexPath.row;
    cell.btnRecall.tag = indexPath.row;
    [self configureCell:cell message:message];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)configureCell:(MessageCell *)cell message:(LTMessageResponse *)message {
    if (message.recallStatus) {
        cell.btnRecall.hidden = YES;
        cell.btnDelete.hidden = YES;
        if ([message isKindOfClass:[LTRecallResponse class]]) {
            LTRecallResponse *recall = (LTRecallResponse *)message;
            cell.lblMessage.text = @"Recall a message.";
            cell.lblDetail.text = [NSString stringWithFormat:@"RecallMsgID is %@", recall.recallMsgID];
            return;
        } else {
            cell.lblMessage.text = @"This message is recalled.";
            cell.lblDetail.text = [NSString stringWithFormat:@"By %@", message.recallStatus.recallBy];
        }
        return;
    }
    
    cell.btnRecall.hidden = NO;
    cell.btnDelete.hidden = NO;
    cell.lblDetail.text = @"";
    if ([message isKindOfClass:[LTSendMessageResponse class]]) {
        LTSendMessageResponse *sendMessage = (LTSendMessageResponse *)message;
        cell.lblMessage.text = [NSString stringWithFormat:@"Sent a %@.", [sendMessage.message class]];
        if ([sendMessage.message isKindOfClass:[LTTextMessage class]]) {
            LTTextMessage *textMessage = (LTTextMessage *)sendMessage.message;
            cell.lblDetail.text = textMessage.msgContent;
        } else if ([sendMessage.message isKindOfClass:[LTFileMessage class]]) {
            LTFileMessage *fileMessage = (LTFileMessage *)sendMessage.message;
            cell.lblDetail.text = fileMessage.fileName;
        }
    } else if ([message isKindOfClass:[LTJoinChannelResponse class]]) {
        cell.lblMessage.text = @"Joined this chat.";
    } else if ([message isKindOfClass:[LTCreateChannelResponse class]]) {
        cell.lblMessage.text = @"Create this chat.";
        LTCreateChannelResponse *create = (LTCreateChannelResponse *)message;
        NSString *detail = [self detailWithMembers:create.members];
        cell.lblDetail.text = [NSString stringWithFormat:@"Members consist of %@", detail];
    } else if ([message isKindOfClass:[LTInviteMemberResponse class]]) {
        cell.lblMessage.text = @"Invite";
        LTInviteMemberResponse *invite = (LTInviteMemberResponse *)message;
        cell.lblDetail.text = [self detailWithMembers:invite.members];
    } else if ([message isKindOfClass:[LTLeaveChannelResponse class]]) {
        cell.lblMessage.text = @"Left.";
    } else if ([message isKindOfClass:[LTKickMemberResponse class]]) {
        cell.lblMessage.text = @"Kick";
        LTKickMemberResponse *kick = (LTKickMemberResponse *)message;
        cell.lblDetail.text = [self detailWithMembers:kick.members];
    } else if ([message isKindOfClass:[LTMemberRoleResponse class]]) {
        cell.lblMessage.text = @"Set member role.";
        LTMemberRoleResponse *memberRole = (LTMemberRoleResponse *)message;
        NSString *roleString = @"unknow";
        if (memberRole.roleID == LTChannelRoleOutcast) {
            roleString = @"Outcast";
        } else if (memberRole.roleID == LTChannelRoleInvited) {
            roleString = @"Invieted";
        } else if (memberRole.roleID == LTChannelRoleParticipant) {
            roleString = @"Participant";
        } else if (memberRole.roleID == LTChannelRoleModerator) {
            roleString = @"Moderator";
        } else if (memberRole.roleID == LTChannelRoleAdmin) {
            roleString = @"Admin";
        }
        
        cell.lblDetail.text = [NSString stringWithFormat:@"%@'s role is %@ now.", memberRole.memberUserID, roleString];
    } else if ([message isKindOfClass:[LTChannelProfileResponse class]]) {
        LTChannelProfileResponse *channelProfile = (LTChannelProfileResponse *)message;
        cell.lblMessage.text = @"Set this chat profile.";
        NSArray *allKeys = [channelProfile.channelProfile allKeys];
        NSString *string = [allKeys componentsJoinedByString:@", "];
        if (string.length > 0) {
            cell.lblDetail.text = [NSString stringWithFormat:@"Change %@.", string];
        }
    } else if ([message isKindOfClass:[LTDeleteMessagesResponse class]]) {
        LTDeleteMessagesResponse *deleteMessage = (LTDeleteMessagesResponse *)message;
        cell.lblMessage.text = @"Delete message.";
        cell.lblDetail.text = deleteMessage.deleteMsgID;
        cell.btnRecall.hidden = YES;
        cell.btnDelete.hidden = YES;
    } else {
        cell.lblMessage.text = [NSString stringWithFormat:@"%@", [message class]];
    }
}

- (NSString *)detailWithMembers:(NSSet *)members {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (LTMemberProfile *member in members) {
        if (member.nickname.length > 0) {
            [array addObject:member.nickname];
        } else if (member.userID.length > 0) {
            [array addObject:member.userID];
        }
    }
    
    NSString *string = [array componentsJoinedByString:@", "];
    return string;
}

//MARK: - MessageCellDelegate

- (void)messageCellDidSelectRecallWithRow:(NSUInteger)row {
    LTMessageResponse *message = self.messageArray[row];
    
    if (![message.senderID isEqualToString:[IMManager sharedInstance].currentUser.userID]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Only can recall self message." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.activityView startAnimating];
    if (message) {
        [[IMManager sharedInstance] recallLTMessageWithMsgID:message.msgID];
    }
}

- (void)messageCellDidSelectDeleteWithRow:(NSUInteger)row {
    LTMessageResponse *message = self.messageArray[row];
    [self.activityView startAnimating];
    if (message) {
        [[IMManager sharedInstance] deleteLTMessageWithMsgID:message.msgID];
    }
}

//MARK: - IMManagerDelegate

- (void)onDidSendMessage {
    [[IMManager sharedInstance] queryMessages];
}

- (void)onQueryMessages:(NSArray<LTMessageResponse *> *)messages {
    [self.activityView stopAnimating];
    self.messageTVC.hidden = NO;
    [self.messageArray setArray:messages];
    [self.messageTVC reloadData];
}

- (void)onIncomingMessage:(LTMessageResponse *)message {
    [self.messageArray insertObject:message atIndex:0];
    [self.messageTVC reloadData];
}

- (void)onNeedQueryMessage {
    [self.activityView startAnimating];
    self.messageTVC.hidden = YES;
    [[IMManager sharedInstance] queryMessages];
}

@end
