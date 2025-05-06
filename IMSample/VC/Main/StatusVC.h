//
//  StatusVC.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusVC : UIViewController

+ (StatusVC *)sharedInstance;

- (void)hintWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
