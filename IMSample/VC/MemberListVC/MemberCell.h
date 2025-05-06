//
//  MemberCell.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MemberCell;
@protocol MemberCellDelegate <NSObject>
@optional
- (void)didClickKick:(MemberCell *)cell;
@end

@interface MemberCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel *lblNickname;

@property(nonatomic, strong) IBOutlet UILabel *lblUserID;

@property(nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
