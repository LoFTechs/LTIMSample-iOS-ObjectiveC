//
//  CreateMemberCell.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CreateMemberCell;
@protocol CreateMemberDelegate <NSObject>
@optional
- (void)didClickUserID:(CreateMemberCell *)cell;
- (void)didClickRole:(CreateMemberCell *)cell;
@end

@interface CreateMemberCell : UITableViewCell

@property(nonatomic, weak) id delegate;

@property(nonatomic, strong) IBOutlet UITextField *txtFieldUserID;
@property(nonatomic, strong) IBOutlet UITextField *txtFieldNickname;
@property(nonatomic, strong) IBOutlet UIButton *btnRole;

@property(nonatomic, assign) BOOL canSelectRole;

@end

NS_ASSUME_NONNULL_END
