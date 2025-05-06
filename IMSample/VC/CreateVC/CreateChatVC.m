//
//  CreateChatVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/12.
//

#import "CreateChatVC.h"
#import "AppUtility.h"
#import "CreateMemberCell.h"
#import "IMManager.h"
#import "StatusVC.h"
#import "UserInfo.h"

@interface CreateChatVC()<UITableViewDelegate, UITableViewDataSource, CreateMemberDelegate, IMManagerDelegate>
@property (nonatomic, strong) IBOutlet UIButton *btnChannelType;
@property (nonatomic, strong) IBOutlet UITextField *txtFieldSubject;
@property (nonatomic, strong) IBOutlet UIView *viewGroup;
@property (nonatomic, strong) IBOutlet UILabel *lblCount;
@property (nonatomic, strong) IBOutlet UITableView *createMemberTV;
@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *createMemberModelArray;
@end

typedef NS_ENUM(NSInteger, SelectType) {
    SelectTypePhoneNumber,
    SelectTypeSemiUID,
    SelectTypeUserID
};

@implementation CreateChatVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.isSingle = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    LTMemberModel *member = [[LTMemberModel alloc] init];
    _createMemberModelArray = [[NSMutableArray alloc] initWithObjects:member, nil];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [[IMManager sharedInstance] addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[IMManager sharedInstance] removeDelegate:self];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)initViews {
    [self.createMemberTV registerNib:[UINib nibWithNibName:@"CreateMemberCell" bundle:nil] forCellReuseIdentifier:@"CreateMemberCell"];
}

- (NSUInteger)memberCount {
    if (self.isSingle) {
        return 1;
    }
    
    return self.count;
}

- (void)setIsSingle:(BOOL)isSingle {
    if (_isSingle == isSingle) {
        return;
    }
    
    _isSingle = isSingle;
    self.viewGroup.hidden = isSingle;
    if (isSingle) {
        [self.btnChannelType setTitle:@"Single" forState:UIControlStateNormal];
        self.btnChannelType.tag = 0;
    } else {
        [self.btnChannelType setTitle:@"Group" forState:UIControlStateNormal];
        self.btnChannelType.tag = 1;
    }
    
    [self.createMemberTV reloadData];
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
- (IBAction)clickChannelType {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Channel Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *single = [UIAlertAction actionWithTitle:@"Single" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isSingle = YES;
    }];
    [alert addAction:single];
    
    UIAlertAction *group = [UIAlertAction actionWithTitle:@"Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isSingle = NO;
    }];
    [alert addAction:group];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clickMemberCount:(UIButton *)sender {
    if (sender.tag == 0) {
        if (self.count < 2) {
            return;
        }
        _count--;
        [self.createMemberModelArray removeObjectAtIndex:self.createMemberModelArray.count - 1];
    } else {
        _count++;
        LTMemberModel *member = [[LTMemberModel alloc] init];
        [self.createMemberModelArray addObject:member];
    }
    self.lblCount.text = [NSString stringWithFormat:@"%@", @(self.count)];
    [self.createMemberTV reloadData];
}

- (IBAction)clickCreate {
    if (self.isSingle) {
        LTMemberModel *member = self.createMemberModelArray.firstObject;
        [[IMManager sharedInstance] createSingleChannelWithMember:member];
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        LTMemberModel *member = [[LTMemberModel alloc] init];
        member.userID = [IMManager sharedInstance].currentUser.userID;
        member.roleID = LTChannelRoleAdmin;
        [dict setObject:member forKey:member.userID];

        for (LTMemberModel *member in self.createMemberModelArray) {
            [dict setObject:member forKey:member.userID];
        }
        
        [[IMManager sharedInstance] createGroupChannelWithMembers:dict.allValues subject:self.txtFieldSubject.text];
    }
}

- (IBAction)keyboardEnd {
    [self.view.window endEditing:YES];
}

//MARK: UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

//MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self memberCount];
}

- (CreateMemberCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateMemberCell"];
    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.canSelectRole = !self.isSingle;
    
    LTMemberModel *member = self.createMemberModelArray[indexPath.row];
    cell.txtFieldUserID.text = member.userID;
    cell.txtFieldNickname.text = member.chNickname;
    [cell.btnRole setTitle:[[self roleStringMap] objectForKey:@(member.roleID)] forState:UIControlStateNormal];
    
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
                        LTMemberModel *member = self.createMemberModelArray[cell.tag];
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
                        LTMemberModel *member = self.createMemberModelArray[cell.tag];
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

- (void)didClickRole:(CreateMemberCell *)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Role" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    LTMemberModel *member = self.createMemberModelArray[cell.tag];
    
    NSDictionary *roleMap = [self roleStringMap];
    NSArray *array = [self allRoleArray];
    for (NSNumber *role in array) {
        if (member.roleID == [role unsignedIntegerValue]) {
            continue;
        }
        
        NSString *roleString = roleMap[role];
        UIAlertAction *action = [UIAlertAction actionWithTitle:roleString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            member.roleID = [role unsignedIntegerValue];
            [cell.btnRole setTitle:[[self roleStringMap] objectForKey:@(member.roleID)] forState:UIControlStateNormal];
        }];
        [alert addAction:action];
    }

    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: IMManagerDelegate
- (void)onCreateChannel:(NSString *)chID {
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[IMManager sharedInstance] queryChannelWithChID:chID];
    });
}

@end
