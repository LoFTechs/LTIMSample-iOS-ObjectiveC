//
//  InviteVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/13.
//

#import "InviteMemberVC.h"
#import "AppUtility.h"
#import "CreateMemberCell.h"
#import "IMManager.h"
#import "UserInfo.h"

@interface InviteMemberVC()<UITableViewDelegate, UITableViewDataSource, CreateMemberDelegate>
@property (nonatomic, strong) IBOutlet UILabel *lblCount;
@property (nonatomic, strong) IBOutlet UITableView *inviteMemberTV;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *inviteMemberModelArray;
@end

@implementation InviteMemberVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    LTMemberModel *member = [[LTMemberModel alloc] init];
    _inviteMemberModelArray = [[NSMutableArray alloc] initWithObjects:member, nil];
    [self initViews];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)initViews {
    [self.inviteMemberTV registerNib:[UINib nibWithNibName:@"CreateMemberCell" bundle:nil] forCellReuseIdentifier:@"CreateMemberCell"];
}

- (NSDictionary *)roleStringMap {
    return @{@(LTChannelRoleNone):@"LTChannelRoleNone",
             @(LTChannelRoleOutcast):@"LTChannelRoleOutcast",
             @(LTChannelRoleInvited):@"LTChannelRoleInvited",
             @(LTChannelRoleParticipant):@"LTChannelRoleParticipant",
             @(LTChannelRoleModerator):@"LTChannelRoleModerator",
             @(LTChannelRoleAdmin):@"LTChannelRoleAdmin"};
}

- (NSArray *)allRoleArray {
    return @[@(LTChannelRoleNone),
             @(LTChannelRoleOutcast),
             @(LTChannelRoleInvited),
             @(LTChannelRoleParticipant),
             @(LTChannelRoleModerator),
             @(LTChannelRoleAdmin)];
}

//MARK: IBAction
- (IBAction)clickMemberCount:(UIButton *)sender {
    if (sender.tag == 0) {
        if (self.count < 2) {
            return;
        }
        _count--;
        [self.inviteMemberModelArray removeObjectAtIndex:self.inviteMemberModelArray.count - 1];
    } else {
        _count++;
        LTMemberModel *member = [[LTMemberModel alloc] init];
        [self.inviteMemberModelArray addObject:member];
    }
    self.lblCount.text = [NSString stringWithFormat:@"%@", @(self.count)];
    [self.inviteMemberTV reloadData];
}

- (IBAction)clickInvite {
    [[IMManager sharedInstance] inviteWithMembers:self.inviteMemberModelArray];
}

//MARK: UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

//MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inviteMemberModelArray.count;
}

- (CreateMemberCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateMemberCell"];
    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.canSelectRole = YES;
    
    LTMemberModel *member = self.inviteMemberModelArray[indexPath.row];
    cell.txtFieldUserID.text = member.userID;
    cell.txtFieldNickname.text = member.chNickname;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//MARK: CreateMemberDelegate
- (void)didClickUserID:(CreateMemberCell *)cell {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Member from.." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Input phonenumber or semiUID...";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"PhoneNumber" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *nickName = [alert.textFields firstObject].text;
        NSString *message = [alert.textFields lastObject].text;
        if (message.length > 0) {
            [LTSDK getUserStatusWithPhoneNumbers:@[message] completion:^(LTResponse * _Nonnull response, NSArray<LTUserStatus *> * _Nullable userStatuses) {
                [self getUserStatusWithResponse:response userStatuses:userStatuses completion:^(NSString *userID) {
                    if (userID.length > 0) {
                        cell.txtFieldUserID.text = userID;
                        LTMemberModel *member = self.inviteMemberModelArray[cell.tag];
                        member.userID = userID;
                        member.chNickname = nickName;

                    }
                }];
            }];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"SemiUID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *nickName = [alert.textFields firstObject].text;
        NSString *message = [alert.textFields lastObject].text;
        if (message.length > 0) {
            [LTSDK getUserStatusWithSemiUIDs:@[message] completion:^(LTResponse * _Nonnull response, NSArray<LTUserStatus *> * _Nullable userStatuses) {
                [self getUserStatusWithResponse:response userStatuses:userStatuses completion:^(NSString *userID) {
                    if (userID.length > 0) {
                        cell.txtFieldUserID.text = userID;
                        LTMemberModel *member = self.inviteMemberModelArray[cell.tag];
                        member.userID = userID;
                        member.chNickname = nickName;
                    }
                }];
            }];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)getUserStatusWithResponse:(LTResponse *)response userStatuses:(NSArray<LTUserStatus *> *)userStatuses completion:(void(^)(NSString *userID))completion {
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response.returnCode == LTReturnCodeSuccess) {
                LTUserStatus *userStatus = userStatuses.firstObject;
                if (userStatus.canIM) {
                    completion(userStatus.userID);
                } else if (userStatus.userID.length == 0) {
                    [AppUtility alertWithString:@"This user does not exist" consoleString:@""];
                    completion(nil);
                } else {
                    [AppUtility alertWithString:@"This user can not IM" consoleString:@""];
                    completion(nil);
                }
            } else {
                [AppUtility alertWithString:response.returnMessage consoleString:@""];
                completion(nil);
            }
        });
    }
}

@end
