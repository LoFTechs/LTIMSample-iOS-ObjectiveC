//
//  MessageCell.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MessageCellDelegate <NSObject>
@optional

- (void)messageCellDidSelectRecallWithRow:(NSUInteger)row;
- (void)messageCellDidSelectDeleteWithRow:(NSUInteger)row;

@end

@interface MessageCell : UITableViewCell

@property (nonatomic, weak) id<MessageCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *lblSender;
@property (nonatomic, strong) IBOutlet UILabel *lblMessage;
@property (nonatomic, strong) IBOutlet UILabel *lblDetail;
@property (nonatomic, strong) IBOutlet UILabel *lblSendTime;
@property (nonatomic, strong) IBOutlet UIButton *btnRecall;
@property (nonatomic, strong) IBOutlet UIButton *btnDelete;

@end

NS_ASSUME_NONNULL_END
