//
//  AppDelegate.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/4.
//

#import "AppDelegate.h"
#import "StatusVC.h"
#import "IMManager.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    self.window.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height - 50);
    [[IMManager sharedInstance] initSDK];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([IMManager sharedInstance].enableConnect) {
        [[IMManager sharedInstance] connect];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([IMManager sharedInstance].enableConnect) {
        [[IMManager sharedInstance] disconnect];
    }
}

//MARK: APNS
- (void)registAPNSWithCompletion:(void (^)(BOOL success))completion {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    [[StatusVC sharedInstance] hintWithString:@"APNS request authorization succeeded!"];
                }
                
                if (completion) {
                    completion(granted);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *console = [NSString stringWithFormat:@"ERROR: %@ - %@\nSUGGESTIONS: %@ - %@", error.localizedFailureReason, error.localizedDescription, error.localizedRecoveryOptions, error.localizedRecoverySuggestion];
                [[StatusVC sharedInstance] hintWithString:console];
                if (completion) {
                    completion(NO);
                }
            });
        }
    }];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *apnsToken = [self hexadecimalStringFromData:deviceToken];
    [[IMManager sharedInstance] setPushToken:apnsToken];
    [[StatusVC sharedInstance] hintWithString:@"Receive APNS token!"];
    NSLog(@"apnsToken = %@", apnsToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[StatusVC sharedInstance] hintWithString:@"Register APNS error!"];
    NSLog(@"error = %@", error);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    LTPushNotificationMessage *apnsMessage = [LTSDK parsePushNotificationWithNotify:response.notification.request.content.userInfo];
    [[IMManager sharedInstance] clickAPNS:apnsMessage];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

- (NSString *)hexadecimalStringFromData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
    
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

@end
