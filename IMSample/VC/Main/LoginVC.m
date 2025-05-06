//
//  LoginVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/5.
//

#import "LoginVC.h"
#import "IMManager.h"
#import "StatusVC.h"
#import "UserInfo.h"

@interface LoginVC()<IMManagerDelegate>
@property (nonatomic, strong) IBOutlet UILabel *lblUserID;
@property (nonatomic, strong) IBOutlet UIButton *btnConnect;
@property (nonatomic, strong) IBOutlet UIButton *btnDisconnect;
@property (nonatomic, strong) IBOutlet UIButton *btnSetPushToken;
@property (nonatomic, strong) IBOutlet UIButton *btnProfile;
@property (nonatomic, strong) IBOutlet UIButton *btnIM;
@end

@implementation LoginVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [[IMManager sharedInstance] addDelegate:self];
    [self initViews];
}

- (void)initViews {
    self.lblUserID.text = [UserInfo userID];
    if ([IMManager sharedInstance].initSuccess) {
        self.btnConnect.hidden = NO;
        self.btnDisconnect.hidden = NO;
    }
}

//MARK: IBAction
- (IBAction)clickConnect {
    [IMManager sharedInstance].enableConnect = YES;
    [[IMManager sharedInstance] connect];
}

- (IBAction)clickDisconnect {
    [IMManager sharedInstance].enableConnect = NO;
    [[IMManager sharedInstance] disconnect];
}

- (IBAction)clickSetPushToken {
    [[IMManager sharedInstance] setupAPNS];
}

//MARK: IMManagerDelegate
- (void)onInit:(BOOL)success {
    if (success) {
        self.btnConnect.hidden = NO;
        self.btnDisconnect.hidden = NO;
    }
}

- (void)onConnected {
    self.btnIM.hidden = NO;
    self.btnProfile.hidden = NO;
    self.btnSetPushToken.hidden = NO;
}

- (void)onDisconnected {
    self.btnIM.hidden = YES;
    self.btnProfile.hidden = YES;
    self.btnSetPushToken.hidden = YES;
}

@end
