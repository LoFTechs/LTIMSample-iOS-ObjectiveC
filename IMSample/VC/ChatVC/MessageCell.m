//
//  MessageCell.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import "MessageCell.h"

@interface MessageCell()

@end

@implementation MessageCell

- (IBAction)clickBtnRecall:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(messageCellDidSelectRecallWithRow:)]) {
        [self.delegate messageCellDidSelectRecallWithRow:sender.tag];
    }
}

- (IBAction)clickBtnDelete:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(messageCellDidSelectDeleteWithRow:)]) {
        [self.delegate messageCellDidSelectDeleteWithRow:sender.tag];
    }
}

@end
