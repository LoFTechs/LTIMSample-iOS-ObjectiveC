//
//  MemberListVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import "MemberListVC.h"
#import "MemberCell.h"
#import "IMManager.h"

@interface MemberListVC()<UITableViewDelegate, UITableViewDataSource, IMManagerDelegate, MemberCellDelegate>
@property (nonatomic, strong) IBOutlet UITableView *memberTV;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSString *lastUserID;
@property (nonatomic, assign) BOOL isQuerying;
@property (nonatomic, assign) BOOL isDone;
@property (nonatomic, assign) BOOL needQueryAgain;
@end

@implementation MemberListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _memberArray = [[NSMutableArray alloc] init];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IMManager sharedInstance] addDelegate:self];
    [self.memberArray removeAllObjects];
    self.memberTV.hidden = YES;
    _lastUserID = @"";
    _isDone = NO;
    [self queryMember];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IMManager sharedInstance] removeDelegate:self];
}

- (void)initViews {
    [self.memberTV registerNib:[UINib nibWithNibName:@"MemberCell" bundle:nil] forCellReuseIdentifier:@"MemberCell"];
}

- (void)queryMember {
    if ([self canQuery]) {
        _isQuerying = YES;
        [self.activityView startAnimating];
        [[IMManager sharedInstance] queryChannelMemberWithLastUserID:self.lastUserID count:[self batchCount]];
    } else if (self.isQuerying) {
        _needQueryAgain = YES;
    }
}

- (BOOL)canQuery {
    return !(self.isDone || self.isQuerying);
}

- (NSUInteger)batchCount {
    return 30;
}

//MARK: UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MemberCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row + 1 == self.memberArray.count) {
        [self queryMember];
    }
}

//MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberArray.count;
}

- (MemberCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    cell.delegate = self;
    cell.tag = indexPath.row;
    LTMemberPrivilege *member = self.memberArray[indexPath.row];
    NSString *nickname = @"No nickname";
    if (member.nickname.length > 0) {
        nickname = member.nickname;
    } else if (member.phoneNumber.length > 0) {
        nickname = member.phoneNumber;
    }
    cell.lblNickname.text = nickname;
    cell.lblUserID.text = member.userID;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//MARK: IMManagerDelegate
- (void)onQueryChannelMembers:(LTQueryChannelMembersResponse *)response {
    _isQuerying = NO;
    self.memberTV.hidden = NO;
    [self.activityView stopAnimating];
    
    if (response.members.count > 0) {
        [self.memberArray addObjectsFromArray:response.members];
        _lastUserID = response.members.lastObject.userID;
    }
    if (response.members.count < [self batchCount]) {
        _isDone = YES;
    } else {
        _isDone = NO;
    }
    
    if (self.needQueryAgain) {
        [self queryMember];
    }
    
    [self.memberTV reloadData];
}

- (void)onMemberChanged {
    [self.memberArray removeAllObjects];
    self.memberTV.hidden = YES;
    _lastUserID = @"";
    _isDone = NO;
    [self queryMember];
}

//MARK: MemberCellDelegate
- (void)didClickKick:(MemberCell *)cell {
    LTMemberPrivilege *member = self.memberArray[cell.tag];
    [[IMManager sharedInstance] kickUser:member.userID];
}

@end
