//
//  DemoViewController.m
//  MQTT封装Demo
//
//  Created by jaime on 2019/9/19.
//  Copyright © 2019 qinghua.ios. All rights reserved.
//

#import "DemoViewController.h"
#import "FCMQTTManager.h"

@interface DemoViewController ()<FCMQTTManagerDelegate>

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[FCMQTTManager sharedManager] setDelegate:self];    
}

#pragma mark - FC MQTT Manager Delegate
- (void)sessionManager:(MQTTSessionManager *_Nonnull)sessionManager didReceiveMessage:(NSDictionary *_Nullable)massage onTopic:(NSString *_Nonnull)topic {
    
}

- (void)sessionManagerDidFailureCode:(NSInteger)errorCode errorMessage:(NSDictionary *_Nullable)massage onTopic:(NSString *_Nonnull)topic {
    
}

@end
