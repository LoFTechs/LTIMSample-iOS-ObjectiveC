//
//  MemberCell.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import "MemberCell.h"

@interface MemberCell()
@property(nonatomic, strong) IBOutlet UIButton *btnKick;
@end

@implementation MemberCell
//MARK: IBAction
- (IBAction)clickKick {
    if ([self.delegate respondsToSelector:@selector(didClickKick:)]) {
        [self.delegate didClickKick:self];
    }
}

@end
