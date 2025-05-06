//
//  AppDelegate.h
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/4.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//MARK: APNS
- (void)registAPNSWithCompletion:(void (^)(BOOL success))completion;

@end

