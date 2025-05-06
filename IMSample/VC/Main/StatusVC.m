//
//  StatusVC.m
//  LTIMSample
//
//  Created by Sheng-Tsang Uou on 2021/1/5.
//

#import "StatusVC.h"
#import "IMManager.h"
#import "AppDelegate.h"

@interface StatusVC()<IMManagerDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *lblStatus;
@end

@implementation StatusVC
+ (StatusVC *)sharedInstance {
    static StatusVC *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (StatusVC *)init {
    self = [super init];
    if (self) {
        [[IMManager sharedInstance] addDelegate:self];
        [self initWindow];
    }
    return self;
}

- (void)initWindow {
    _window = [[UIWindow alloc] init];
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = 50;
    self.window.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - h, w, h);
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.rootViewController = self;
    self.window.hidden = NO;
    self.window.backgroundColor = [UIColor clearColor];
    self.window.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews {
    _lblStatus = [[UILabel alloc] init];
    self.lblStatus.font = [UIFont systemFontOfSize:14];
    self.lblStatus.contentMode = UIViewContentModeTop;
    self.lblStatus.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.lblStatus];
    [NSLayoutConstraint activateConstraints:@[
        [self.lblStatus.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10],   // 貼齊上緣，可加間距
        [self.lblStatus.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],      // 水平置中
    ]];
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)hintWithString:(NSString *)string {
    self.lblStatus.text = string;
    [self.lblStatus sizeToFit];
    
    CGFloat x = (CGRectGetWidth(self.window.bounds) - CGRectGetWidth(self.lblStatus.bounds)) * 0.5;
    CGFloat y = CGRectGetHeight(self.window.bounds) - CGRectGetHeight(self.lblStatus.bounds) - 4;
    CGRect frame = self.lblStatus.frame;
    frame.origin = CGPointMake(x, y);
    self.lblStatus.frame = frame;
    
    NSLog(@"%@", string);
}

//MARK: IMManagerDelegate
- (void)onConnected {
    [self hintWithString:@"Connected"];
    self.view.backgroundColor = [UIColor greenColor];
}

- (void)onDisconnected {
    [self hintWithString:@"Disconnected"];
    self.view.backgroundColor = [UIColor redColor];
}


@end
