//
//  ChatSettingVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import "ChatSettingVC.h"
#import "IMManager.h"
#import "StatusVC.h"
#import "UserInfo.h"

@interface ChatSettingVC()<IMManagerDelegate>
@property (nonatomic, strong) IBOutlet UITextField *txtFieldSubject;
@property (nonatomic, strong) IBOutlet UIButton *btnSubject;
@property (nonatomic, strong) IBOutlet UITextField *txtFieldNickname;
@property (nonatomic, strong) IBOutlet UIButton *btnNickname;
@property (nonatomic, strong) IBOutlet UISwitch *switchMute;
@property (nonatomic, strong) IBOutlet UIButton *btnMemberList;
@property (nonatomic, strong) IBOutlet UIButton *btnDismiss;
@property (nonatomic, strong) IBOutlet UIButton *btnLeave;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, strong) IBOutlet UIView *viewLoading;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, assign) BOOL isMute;
@property (nonatomic, strong) NSString *chID;
@end

@implementation ChatSettingVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _chID = [IMManager sharedInstance].currentChannel.chID;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IMManager sharedInstance] addDelegate:self];
    [[IMManager sharedInstance] queryChannelWithChID:self.chID];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IMManager sharedInstance] removeDelegate:self];
}

- (void)getChannelInfo {
    [self showLoading:YES];
    [[IMManager sharedInstance] queryChannelWithChID:self.chID];
}

- (void)showLoading:(BOOL)isLoading {
    self.viewLoading.hidden = !isLoading;
    self.btnMemberList.hidden = !self.isGroup;
    self.btnDismiss.hidden = !self.isGroup;
    self.btnLeave.hidden = !self.isGroup;
    if (isLoading) {
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
    }
}

//MARK: IBAction
- (IBAction)clickSetSubject {
    [self showLoading:YES];
    [[IMManager sharedInstance] setChannelSubject:self.txtFieldSubject.text];
}

- (IBAction)clickSetNickname {
    [self showLoading:YES];
    [[IMManager sharedInstance] setMyChannelNickname:self.txtFieldNickname.text];
}

- (IBAction)clickMute:(UISwitch *)switchMute {
    [self showLoading:YES];
    [[IMManager sharedInstance] setChannelMute:switchMute.on];
}

- (IBAction)clickDismiss {
    [self showLoading:YES];
    [[IMManager sharedInstance] dismissChannel];
}

- (IBAction)clickLeave {
    [self showLoading:YES];
    [[IMManager sharedInstance] leaveChannel];
}

- (IBAction)keyboardEnd {
    [self.view.window endEditing:YES];
}

//MARK: IMManagerDelegate
- (void)onQueryChannel:(LTChannelResponse *)channel {
    if (!channel) {
        self.viewLoading.hidden = NO;
        self.btnMemberList.hidden = YES;
        self.btnDismiss.hidden = YES;
        self.btnLeave.hidden = YES;
        return;
    }
    
    self.txtFieldSubject.text = channel.subject;
    _subject = channel.subject;
    
    self.switchMute.on = channel.isMute;
    _isMute = channel.isMute;
    
    _isGroup = (channel.chType == LTChannelTypeGroup);
    if (self.isGroup) {
        [self.btnMemberList setTitle:[NSString stringWithFormat:@"MemberList(%@)", @(channel.memberCount)] forState:UIControlStateNormal];
    }
    
    [self showLoading:NO];
}

- (void)onChangeChannelProfile:(LTChannelProfileResponse *)profile {
    if (!profile) {
        if (self.subject) {
            self.txtFieldSubject.text = self.subject;
        }
        [self showLoading:NO];
        return;
    }
    
    NSString *subject = [profile.channelProfile objectForKey:@"subject"];
    if (subject) {
        self.txtFieldSubject.text = subject;
        _subject = subject;
    }
    
    [self showLoading:NO];
}

- (void)onChangeChannelPreference:(LTChannelPreference *)preference {
    if (!preference) {
        if (self.nickname) {
            self.txtFieldNickname.text = self.nickname;
        }
        
        self.switchMute.on = self.isMute;
        [self showLoading:NO];
        return;
    }
    
    self.txtFieldNickname.text = preference.nickname;
    self.switchMute.on = preference.isMute;
    
    _nickname = preference.nickname;
    _isMute = preference.isMute;
    [self showLoading:NO];
}

- (void)onChannelChanged {
    [self showLoading:YES];
    [[IMManager sharedInstance] queryChannelWithChID:self.chID];
}

- (void)onMemberChanged {
    [self showLoading:YES];
    [[IMManager sharedInstance] queryChannelWithChID:self.chID];
}

@end
