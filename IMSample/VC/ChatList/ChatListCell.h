//
//  ChatListCell.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatListCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel *lblSubject;
@property(nonatomic, strong) IBOutlet UILabel *lblMessage;
@property(nonatomic, strong) IBOutlet UILabel *lblSendTime;

@end

NS_ASSUME_NONNULL_END
