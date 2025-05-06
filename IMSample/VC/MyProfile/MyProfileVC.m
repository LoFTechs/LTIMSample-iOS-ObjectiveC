//
//  MyProfileVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/5.
//

#import "MyProfileVC.h"
#import "IMManager.h"

@interface MyProfileVC()<IMManagerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtFieldNickname;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) IBOutlet UISwitch *switchMute;
@property (strong, nonatomic) IBOutlet UISwitch *switchDisplay;
@property (strong, nonatomic) IBOutlet UISwitch *switchDisplayContent;
@property (strong, nonatomic) LTQueryUserDeviceNotifyResponse *apnsSetting;
@end

@implementation MyProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IMManager sharedInstance] addDelegate:self];
    [[IMManager sharedInstance] queryMyUserProfile];
    [[IMManager sharedInstance] queryMyApnsSetting];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IMManager sharedInstance] removeDelegate:self];
}

//MARK: IBAction
- (IBAction)clickSetNickname:(UIButton *)sender {
    [[IMManager sharedInstance] setMyNickname:self.txtFieldNickname.text];
}

- (IBAction)clickMute:(UISwitch *)switchMute {
    [[IMManager sharedInstance] setApnsMute:switchMute.on];
}

- (IBAction)clickDisplay:(UISwitch *)switchDisplay {
    [[IMManager sharedInstance] setApnsDisplaySender:self.switchDisplay.on displayContent:self.switchDisplayContent.on];
}

- (IBAction)keyboardEnd {
    [self.view.window endEditing:YES];
}

//MARK: IMManagerDelegate
- (void)onQueryMyUserProfile:(LTUserProfile *)userProfile {
    if (userProfile) {
        _nickname = userProfile.nickname;
    }
    self.txtFieldNickname.text = self.nickname;
}

- (void)onQueryMyApnsSetting:(LTQueryUserDeviceNotifyResponse *)myApnsSetting {
    if (myApnsSetting) {
        _apnsSetting = myApnsSetting;
    }
    self.switchMute.on = myApnsSetting.notifyData.isMute;
    self.switchDisplay.on = !myApnsSetting.notifyData.hidingCaller;
    self.switchDisplayContent.on = !myApnsSetting.notifyData.hidingContent;
}

- (void)onSetMyNickname:(NSDictionary *)userProfile {
    if (!userProfile) {
        self.txtFieldNickname.text = self.nickname;
    }
}

- (void)onNeedQueryMyProfile {
    [[IMManager sharedInstance] queryMyUserProfile];
}

- (void)onSetApnsMute:(BOOL)success {
    if (!success) {
        self.switchMute.on = self.apnsSetting.notifyData.isMute;
        self.switchDisplay.on = !self.apnsSetting.notifyData.hidingCaller;
        self.switchDisplayContent.on = !self.apnsSetting.notifyData.hidingContent;
    }
}

- (void)onSetApnsDisplay:(BOOL)success {
    if (!success) {
        self.switchMute.on = self.apnsSetting.notifyData.isMute;
        self.switchDisplay.on = !self.apnsSetting.notifyData.hidingCaller;
        self.switchDisplayContent.on = !self.apnsSetting.notifyData.hidingContent;
    }
}

@end
