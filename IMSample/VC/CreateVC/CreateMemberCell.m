//
//  CreateMemberCell.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/12.
//

#import "CreateMemberCell.h"

@interface CreateMemberCell()<UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblRole;
@end

@implementation CreateMemberCell
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    self.lblTitle.text = [NSString stringWithFormat:@"User %@", @(tag + 1)];
}

- (void)setCanSelectRole:(BOOL)canSelectRole {
    _canSelectRole = canSelectRole;
    self.lblRole.hidden = !canSelectRole;
    self.btnRole.hidden = !canSelectRole;
}

//MARK: IBAction
- (IBAction)clickUserID {
    if ([self.delegate respondsToSelector:@selector(didClickUserID:)]) {
        [self.delegate didClickUserID:self];
    }
}

- (IBAction)clickRole {
    if ([self.delegate respondsToSelector:@selector(didClickRole:)]) {
        [self.delegate didClickRole:self];
    }
}

- (IBAction)keyboardEnd {
    [self.window endEditing:YES];
}


@end


